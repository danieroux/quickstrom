module Quickstrom.Spec
  ( Path
  , Action(..)
  , ActionSequence(..)
  , Actions
  , ProbabilisticAction
  , clicks
  , focus
  , foci
  , keyPress
  , asciiKeyPresses
  , SpecialKey(..)
  , specialKeyPress
  ) where

import Prelude
import Quickstrom.Selector (Selector)
import Data.Tuple (Tuple(..))
import Data.Array (range)
import Data.Char (fromCharCode)
import Data.Enum (class Enum)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Enum (genericPred, genericSucc)
import Data.Generic.Rep.Ord (genericCompare)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (fromJust)
import Partial.Unsafe (unsafePartial)

-- | URL to a web page, or a relative path within a web site.
type Path
  = String

-- | A possible action to generate. Quickstrom uses action values when searching the
-- | DOM for possible actions to generate and perform.
data Action
  = Focus Selector
  | KeyPress Char
  | EnterText String
  | Click Selector
  | Await Selector
  | AwaitWithTimeoutSecs Int Selector
  | Navigate Path

-- | Either a single action or a fixed sequence of actions.
data ActionSequence = Single Action | Sequence (Array Action)

type ProbabilisticAction = Tuple Int ActionSequence

-- | An array of tuples, containing probabilistic weights and 
-- | action sequences.
type Actions = Array ProbabilisticAction

-- | Generate click actions on common clickable elements.
clicks :: Actions
clicks = [ Tuple 1 (Single $ Click "button"),
           Tuple 1 (Single $ Click "input[type=submit]"),
           Tuple 1 (Single $ Click "a") ]

-- | Generate focus actions on elements matching the given selector.
focus :: Selector -> Action
focus = Focus

-- | Generate focus actions on common focusable elements.
foci :: Actions
foci = [ Tuple 1 (Single $ Focus "input"), Tuple 1 (Single $ Focus "textarea") ]

-- | Generate a key press action with the given character.
keyPress :: Char -> Action
keyPress = KeyPress

-- | Generate key press actions with printable ASCII characters.
asciiKeyPresses :: Array Action
asciiKeyPresses = KeyPress <<< unsafePartial fromJust <<< fromCharCode <$> range 32 126

-- | Generate a key press action with the given special key.
specialKeyPress :: SpecialKey -> Action
specialKeyPress specialKey = KeyPress (specialKeyToChar specialKey)

data SpecialKey
  = KeyAdd
  | KeyAlt
  | KeyArrowDown
  | KeyArrowLeft
  | KeyArrowRight
  | KeyArrowUp
  | KeyBackspace
  | KeyCancel
  | KeyClear
  | KeyCommand
  | KeyControl
  | KeyDecimal
  | KeyDelete
  | KeyDivide
  | KeyDown
  | KeyEnd
  | KeyEnter
  | KeyEquals
  | KeyEscape
  | KeyF1
  | KeyF10
  | KeyF11
  | KeyF12
  | KeyF2
  | KeyF3
  | KeyF4
  | KeyF5
  | KeyF6
  | KeyF7
  | KeyF8
  | KeyF9
  | KeyHelp
  | KeyHome
  | KeyInsert
  | KeyLeft
  | KeyLeftAlt
  | KeyLeftControl
  | KeyLeftShift
  | KeyMeta
  | KeyMultiply
  | KeyNull
  | KeyNumpad0
  | KeyNumpad1
  | KeyNumpad2
  | KeyNumpad3
  | KeyNumpad4
  | KeyNumpad5
  | KeyNumpad6
  | KeyNumpad7
  | KeyNumpad8
  | KeyNumpad9
  | KeyPageDown
  | KeyPageUp
  | KeyPause
  | KeyReturn
  | KeyRight
  | KeySemicolon
  | KeySeparator
  | KeyShift
  | KeySpace
  | KeySubtract
  | KeyTab
  | KeyUp

derive instance eqSpecialKey :: Eq SpecialKey

derive instance genericSpecialKey :: Generic SpecialKey _

instance showSpecialKey :: Show SpecialKey where
  show = genericShow

instance ordSpecialKey :: Ord SpecialKey where
  compare = genericCompare

instance enumSpecialKey :: Enum SpecialKey where
  pred = genericPred
  succ = genericSucc

specialKeyToChar :: SpecialKey -> Char
specialKeyToChar = case _ of
  KeyAdd -> '\xe025'
  KeyAlt -> '\xe00a'
  KeyArrowDown -> '\xe015'
  KeyArrowLeft -> '\xe012'
  KeyArrowRight -> '\xe014'
  KeyArrowUp -> '\xe013'
  KeyBackspace -> '\xe003'
  KeyCancel -> '\xe001'
  KeyClear -> '\xe005'
  KeyCommand -> '\xe03d'
  KeyControl -> '\xe009'
  KeyDecimal -> '\xe028'
  KeyDelete -> '\xe017'
  KeyDivide -> '\xe029'
  KeyDown -> '\xe015'
  KeyEnd -> '\xe010'
  KeyEnter -> '\xe007'
  KeyEquals -> '\xe019'
  KeyEscape -> '\xe00c'
  KeyF1 -> '\xe031'
  KeyF10 -> '\xe03a'
  KeyF11 -> '\xe03b'
  KeyF12 -> '\xe03c'
  KeyF2 -> '\xe032'
  KeyF3 -> '\xe033'
  KeyF4 -> '\xe034'
  KeyF5 -> '\xe035'
  KeyF6 -> '\xe036'
  KeyF7 -> '\xe037'
  KeyF8 -> '\xe038'
  KeyF9 -> '\xe039'
  KeyHelp -> '\xe002'
  KeyHome -> '\xe011'
  KeyInsert -> '\xe016'
  KeyLeft -> '\xe012'
  KeyLeftAlt -> '\xe00a'
  KeyLeftControl -> '\xe009'
  KeyLeftShift -> '\xe008'
  KeyMeta -> '\xe03d'
  KeyMultiply -> '\xe024'
  KeyNull -> '\xe000'
  KeyNumpad0 -> '\xe01a'
  KeyNumpad1 -> '\xe01b'
  KeyNumpad2 -> '\xe01c'
  KeyNumpad3 -> '\xe01d'
  KeyNumpad4 -> '\xe01e'
  KeyNumpad5 -> '\xe01f'
  KeyNumpad6 -> '\xe020'
  KeyNumpad7 -> '\xe021'
  KeyNumpad8 -> '\xe022'
  KeyNumpad9 -> '\xe023'
  KeyPageDown -> '\xe00f'
  KeyPageUp -> '\xe00e'
  KeyPause -> '\xe00b'
  KeyReturn -> '\xe006'
  KeyRight -> '\xe014'
  KeySemicolon -> '\xe018'
  KeySeparator -> '\xe026'
  KeyShift -> '\xe008'
  KeySpace -> '\xe00d'
  KeySubtract -> '\xe027'
  KeyTab -> '\xe004'
  KeyUp -> '\xe013'
