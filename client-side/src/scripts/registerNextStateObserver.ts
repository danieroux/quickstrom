import {
  Selector,
  StateQuery,
  runQuery,
  ObservedState,
  Query,
  Queries,
} from "../queries";
import { toArray } from "../arrays";
import { deepEqual } from "../equality";

namespace Quickstrom {
  function matchesSelector(node: Node, selector: Selector): boolean {
    return node instanceof Element && node.matches(selector);
  }

  async function observeNextStateMutation(
    selector: Selector,
    _stateQuery: StateQuery
  ): Promise<void> {
    return new Promise((resolve) => {
      new MutationObserver((mutations, observer) => {
        const anyMatching = mutations
          .flatMap((mutation) => {
            return [
              [mutation.target],
              toArray(mutation.addedNodes) as Node[],
              toArray(mutation.removedNodes) as Node[],
            ].flat();
          })
          .some((node) => matchesSelector(node, selector));

        if (anyMatching) {
          observer.disconnect();
          resolve();
        }
      }).observe(document, {
        childList: true,
        subtree: true,
        attributes: true,
      });
    });
  }

  async function observeNextPropertyChange(query: Query): Promise<void> {
    return new Promise(async (resolve) => {
      const initial = runQuery(query);
      for (let ms = 100; ; ms = ms * 2) {
        const current = runQuery(query);
        if (!isStateEqual(current, initial)) {
          return resolve();
        }
        await delay(ms);
      }
    });
  }

  async function observeNextStateForStateQuery(
    selector: Selector,
    stateQuery: StateQuery
  ): Promise<void> {
    function observeNextEvent(eventType: string): Promise<void> {
      return new Promise((resolve) => {
        (toArray(document.querySelectorAll(selector)) as Node[]).map(
          (element: Node) => {
            function handler(ev: Event) {
              element.removeEventListener(eventType, handler);
              if (ev.target != null) {
                resolve();
              }
            }
            element.addEventListener(eventType, handler);
          }
        );
      });
    }
    switch (stateQuery.tag) {
      case "attribute":
        return observeNextStateMutation(selector, stateQuery);
      case "property":
        switch (stateQuery.name) {
          case "value":
            return Promise.race(
              ["keyup", "change"].map((eventType) =>
                observeNextEvent(eventType)
              )
            );
          case "disabled":
            return Promise.race([
              observeNextStateMutation(selector, stateQuery),
              observeNextPropertyChange([selector, [stateQuery]]),
            ]);
          default:
            return observeNextStateMutation(selector, stateQuery);
        }
      case "cssValue":
        return Promise.race([
          observeNextStateMutation(selector, stateQuery),
          observeNextPropertyChange([selector, [stateQuery]]),
        ]);
      case "text":
        return observeNextStateMutation(selector, stateQuery);
    }
  }

  async function observeNextStateForQuery(query: Query): Promise<void> {
    return await Promise.race(
      query[1].map((stateQuery) =>
        observeNextStateForStateQuery(query[0], stateQuery)
      )
    );
  }

  export async function observeNextState(
    queries: Queries
  ): Promise<void> {
    return await Promise.race(queries.map(observeNextStateForQuery));
  }

  function isStateEqual(map1: ObservedState, map2: ObservedState): boolean {
    var testVal;
    if (map1.size !== map2.size) {
      return false;
    }
    for (var [key, val] of map1) {
      testVal = map2.get(key);
      // console.log(val, testVal);
      // in cases of an undefined value, make sure the key
      // actually exists on the object so there are no false positives
      if (
        !deepEqual(testVal, val) ||
        (testVal === undefined && !map2.get(key))
      ) {
        return false;
      }
    }
    return true;
  }

  export function delay(ms: number): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(resolve, ms);
    });
  }
}

// @ts-ignore
const [timeoutMs, queries, done] = args;

(function () {
  (window as any).registeredObserver = Promise.race([
    Quickstrom.observeNextState(queries),
    Quickstrom.delay(timeoutMs),
  ]);
  done({ Right: [] });
})();
