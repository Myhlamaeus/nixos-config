import XMonad
import Data.Map (fromList)
import XMonad.Util.EZConfig
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run(spawnPipe)
import System.IO (hPutStrLn)
import XMonad.Hooks.ManageDocks
import XMonad.ManageHook
import qualified XMonad.StackSet as W
import XMonad.Hooks.ManageHelpers
import Data.List (isInfixOf, sort)
import XMonad.Hooks.EwmhDesktops
-- import XMonad.Layout.Fullscreen
import XMonad.Hooks.UrgencyHook

-- Color of current window title in xmobar.
xmobarTitleColor = "#FFB6B0"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- | The available layouts.  Note that each layout is separated by |||, which
-- denotes layout choice.
layout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

data Workspace
  = WOs
  | WMsg
  | WGaming
  | WRead
  | WWatch
  | WListen
  | WN Int
  deriving (Eq)
wNamedCount = 5

instance Show Workspace where
  show WOs     = "1:os"
  show WMsg    = "2:msg"
  show WGaming = "3:gaming"
  show WRead   = "4:read"
  show WWatch  = "5:watch"
  show WListen = "6:listen"
  show (WN n)
    | n + wNamedCount < 9 = show $ n + wNamedCount + 1
    | n + wNamedCount == 9 = "0"
    | otherwise           = show $ n + wNamedCount

instance Enum Workspace where
  toEnum 0 = WOs
  toEnum 1 = WMsg
  toEnum 2 = WGaming
  toEnum 3 = WRead
  toEnum 4 = WWatch
  toEnum 5 = WListen
  toEnum n = WN $ n - wNamedCount

  fromEnum WOs = 0
  fromEnum WMsg = 1
  fromEnum WGaming = 2
  fromEnum WRead = 3
  fromEnum WWatch = 4
  fromEnum WListen = 5
  fromEnum (WN n) = n + wNamedCount

instance Bounded Workspace where
  minBound = toEnum 0
  maxBound = toEnum 10

instance Ord Workspace where
  a <= b = fromEnum a <= fromEnum b

workspaces' :: [Workspace]
workspaces' = [ minBound .. maxBound ]

doShift' = doShift . (show :: Workspace -> String)

main = do
  xmobar <- spawnPipe "xmobar-with-config"
  xmonad
    $ withUrgencyHook NoUrgencyHook
    $ ewmh
    $ docks
    $ def
        { modMask = mod4Mask -- Use Super instead of Alt
        , terminal = "urxvt"
        , focusFollowsMouse = False
        , layoutHook = layout
        , handleEventHook = handleEventHook def <+> fullscreenEventHook
        , logHook = dynamicLogWithPP $ xmobarPP
          { ppOutput = hPutStrLn xmobar
          , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
          , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
          , ppSep = "   "
          }
        , workspaces = fmap show (workspaces' :: [Workspace])
        , manageHook = composeAll
          [ isInfixOf "messages.android.com" <$> title     --> doShift' WMsg
          , isInfixOf "Steam"                <$> title     --> doShift' WGaming
          , isInfixOf "steam"                <$> title     --> doShift' WGaming
          , isInfixOf "calibre"              <$> className --> doShift' WRead
          , isInfixOf "goodreads.com"        <$> title     --> doShift' WRead
          , className =? "Discord"                         --> doShift' WMsg
          , className =? "Xmessage"                        --> doFloat
          ] <+> def
        }
        `additionalKeysP`
        [ ("M-C-l",   spawn "xautolock -locknow")
        , ("M-C-S-l", spawn "systemctl hibernate")
        , ("M-C-r",   spawn "systemctl --user start redshift")
        , ("M-C-S-r", spawn "systemctl --user stop redshift")
        , ("M-0",     windows . W.greedyView . show . (toEnum :: Int -> Workspace) $ 9)
        , ("M-S-0",   windows . W.shift      . show . (toEnum :: Int -> Workspace) $ 9)
        , ("M-p",     spawn "rofi -show run")
        , ("M-S-p",   spawn "rofi -show window")
        ]
