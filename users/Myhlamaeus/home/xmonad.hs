{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeApplications #-}

import Control.Arrow ((&&&), (***))
import Control.Monad (join, (<=<))
import Data.Bifunctor (first)
import Data.List (isInfixOf, sort)
import Data.Map (fromList)
import qualified Data.Map as M
import Data.Word (Word32)
import Foreign.C.Types (CInt)
import System.IO (hPutStrLn)
import XMonad
import XMonad.Actions.CopyWindow
import XMonad.Actions.DynamicProjects
import XMonad.Actions.GridSelect (GSConfig, gridselect, runSelectedAction)
import XMonad.Actions.Minimize (maximizeWindow, minimizeWindow, withMinimized)
import XMonad.Actions.RandomBackground (RandomColor (HSV), randomBg)
import XMonad.Actions.Submap (submap)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Accordion (Accordion (Accordion))
import XMonad.Layout.AutoMaster (autoMaster)
import XMonad.Layout.BoringWindows (boringWindows, clearBoring, focusDown, focusMaster, focusUp, markBoring)
import XMonad.Layout.Circle (Circle (Circle))
import XMonad.Layout.DragPane (DragType (Vertical), dragPane)
import XMonad.Layout.Dwindle (Chirality (..), Dwindle (Spiral))
import qualified XMonad.Layout.Dwindle as Dwindle
import XMonad.Layout.Fullscreen (fullscreenFocus)
import XMonad.Layout.Grid (Grid (Grid))
import XMonad.Layout.Groups (group)
import XMonad.Layout.Minimize (minimize)
import XMonad.ManageHook
import XMonad.Prompt (XPConfig, promptKeymap, vimLikeXPKeymap)
import XMonad.Prompt.Layout (layoutPrompt)
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.Run (spawnPipe)

-- Color of current window title in xmobar.
xmobarTitleColor = "#FFB6B0"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- | The available layouts.  Note that each layout is separated by |||, which
-- denotes layout choice.
layout = minimize . boringWindows . fullscreenFocus . avoidStruts $ tiled ||| autoMaster 1 (1/100) Grid ||| group Full Grid ||| dragPane Vertical 0.1 0.5 ||| Grid ||| Spiral R Dwindle.CW 1.5 1.1 ||| Accordion ||| Circle ||| Full
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
  = WSocial
  | WGaming
  | WRead
  | WMedia
  | WWork
  | WN Int
  | WSecret
  deriving (Eq)
wNamedCount = 6

workspaceName :: Workspace -> String
workspaceName WSecret = "0:secret"
workspaceName WSocial = "1:social"
workspaceName WGaming = "2:gaming"
workspaceName WRead   = "3:read"
workspaceName WMedia  = "4:media"
workspaceName WWork   = "5:work"
workspaceName (WN n)  = show $ n + wNamedCount - 1

instance Enum Workspace where
  toEnum 0 = WSecret
  toEnum 1 = WSocial
  toEnum 2 = WGaming
  toEnum 3 = WRead
  toEnum 4 = WMedia
  toEnum 5 = WWork
  toEnum n = WN $ n - wNamedCount + 1

  fromEnum WSecret = 0
  fromEnum WSocial = 1
  fromEnum WGaming = 2
  fromEnum WRead = 3
  fromEnum WMedia = 4
  fromEnum WWork = 5
  fromEnum (WN n) = n + wNamedCount + 1

instance Bounded Workspace where
  minBound = toEnum 0
  maxBound = toEnum 10

instance Ord Workspace where
  WSecret <= WSecret = True
  WSecret <= _ = False
  _ <= WSecret = True
  a <= b = fromEnum a <= fromEnum b

workspaces' :: [Workspace]
workspaces' = sort [ minBound .. maxBound ]

doShift' = doShift . workspaceName

xpConfig :: XPConfig
xpConfig = def
  { promptKeymap = vimLikeXPKeymap
  }

projects :: [Project]
projects =
  [ Project { projectName = "drawing"
            , projectDirectory = "~/Documents/Paintings"
            , projectStartHook = Just $ gtkSpawn "org.kde.krita.desktop"
            }
  , Project { projectName = "social"
            , projectDirectory = "~"
            , projectStartHook = Just $ do
                gtkSpawn "element-desktop.desktop"
                gtkSpawn "org.telegram.desktop"
            }
  , Project { projectName = "read"
            , projectDirectory = "~"
            , projectStartHook = Just $ do
                gtkSpawn "calibre.desktop"
                gtkSpawn "zotero.desktop"
                gtkSpawn "emacs.desktop"
            }
  , Project { projectName = "game"
            , projectDirectory = "~"
            , projectStartHook = Just $ do
                gtkSpawn "steam.desktop"
            }
  ]
  where
    gtkSpawn name = spawn $ "gtk-launch " <> name
    ghqProject platform owner name =
      Project { projectName = name
              , projectDirectory = "~/.ghq/" <> platform <> "/" <> owner <> "/" <> name
              , projectStartHook = Just $ gtkSpawn "emacs.desktop ."
              }
    gitlabProject = ghqProject "gitlab.com"

additionalKeys' :: XConfig a -> (XConfig a -> [((KeyMask, KeySym), X ())]) -> XConfig a
cfg `additionalKeys'` map = cfg `additionalKeys` (first (first (modMask cfg .|.)) <$> map cfg)

gridselectWindow :: GSConfig Window -> [Window] -> X (Maybe Window)
gridselectWindow cfg = gridselect cfg <=< windowMap
  where
    windowMap = traverse keyValuePair
    keyValuePair w = (, w) <$> windowName w
    windowName = fmap show . getName

main = do
  xmobar <- spawnPipe "xmobar-with-config"
  xmonad
    $ withUrgencyHook NoUrgencyHook
    $ ewmh
    $ docks
    $ dynamicProjects projects
    $ def
        { normalBorderColor = "#999999"
        , focusedBorderColor = "#cc0000"
        , modMask = mod4Mask -- Use Super instead of Alt
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
        , workspaces = fmap workspaceName workspaces'
        , manageHook
          =   composeAll
            [ className =? "keybase"                         --> doShift' WWork
            , className =? "Steam"                           --> doShift' WGaming
            , isInfixOf "openmw"               <$> className --> doShift' WGaming
            , className =? "Dwarf_Fortress"                  --> doShift' WGaming
            , className =? "dwarftherapist"                  --> doShift' WGaming
            , title     =? "dfhack"                          --> doShift' WGaming
            , isInfixOf "calibre"              <$> className --> doShift' WRead
            , isInfixOf "goodreads.com"        <$> title     --> doShift' WRead
            , className =? "Xmessage"                        --> doFloat
            ]
          <+> composeOne
            [ transience
            , isFullscreen -?> (doFullFloat)
            ]
          <+> def
        }
        `additionalKeys'`
        (\cfg ->
            [ ((shiftMask, xK_Return), randomBg (HSV 40 10))
            , ((hyperMask, xK_p),      spawn "sh -c 'xsel | xvkbd -xsendevent -file -'")
            ])
        `additionalKeysP`
        [ ("M-C-l",   spawn "xautolock -locknow")
        , ("M-C-S-l", spawn "systemctl hibernate")
        , ("M-C-r",   spawn "systemctl --user start redshift")
        , ("M-C-S-r", spawn "systemctl --user stop redshift")
        , ("M-0",     windows . W.greedyView . workspaceName $ toEnum 0)
        , ("M-S-0",   windows . W.shift      . workspaceName $ toEnum 0)
        , ("M-p",     spawn "rofi -show run")
        , ("M-S-p",   spawn "rofi -show window")
        , ("M-a",     spawn "rofi -modi drun -show drun")
        , ("M-S-a",   spawn "rofi -show window")
        , ("M-v",     windows copyToAll)
        , ("M-S-v",   killAllOtherCopies)
        , ("M-n",     withFocused pictureInPicture >> markBoring)
        , ("M-S-n",   killAllOtherCopies >> clearBoring)
        , ("M-/",     runSelectedAction def $ (projectName &&& switchProject) <$> projects)
        , ("M-S-/",     runSelectedAction def $ (projectName &&& shiftToProject) <$> projects)
        , ("M--",     withFocused minimizeWindow)
        , ("M-S--",   withMinimized $ maybe (pure ()) maximizeWindow <=< gridselectWindow def)
        , ("M-j",     focusDown)
        , ("M-k",     focusUp)
        , ("M-m",     focusMaster)
        , ("M-x",     layoutPrompt xpConfig)
        ]
  where
    hyperMask = controlMask .|. shiftMask .|. mod1Mask .|. mod4Mask
    moveResizeWindow' :: Window -> Display -> (Position, Position) -> (Dimension, Dimension) -> X ()
    moveResizeWindow' win d (x, y) (w, h) = liftIO $ moveResizeWindow d win x y w h
    pictureInPicture :: Window -> X ()
    pictureInPicture win = whenX (isClient win) $ withDisplay $ \d -> do
      liftIO $ raiseWindow d win
      let (dw, dh) = (join (***) (fromIntegral)) $ (displayWidth d 0, displayHeight d 0)
      let (ww, wh) = (400, ceiling $ 400 / 4 * 3) :: (Dimension, Dimension)
      moveResizeWindow' win d (fromIntegral $ dw - ww - 30, fromIntegral $ dh - wh - 30) (ww, wh)
