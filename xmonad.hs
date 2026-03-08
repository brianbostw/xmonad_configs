import XMonad
import XMonad.Actions.CycleRecentWS (cycleRecentNonEmptyWS)
import XMonad.Actions.CycleWS (swapNextScreen)
import XMonad.Actions.FindEmptyWorkspace (viewEmptyWorkspace, tagToEmptyWorkspace)
import XMonad.Actions.Submap
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WindowBringer (bringMenu)
import XMonad.Layout.NoBorders (noBorders, lessBorders, Ambiguity(..))
import XMonad.Layout.PerScreen (ifWider)
import XMonad.Layout.Tabbed (simpleTabbed)
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch (fuzzyMatch, fuzzySort)
import XMonad.Prompt.RunOrRaise (runOrRaisePrompt)
import XMonad.Prompt.Window (windowPrompt, WindowPrompt(Goto), allWindows)
import XMonad.Util.EZConfig (additionalKeys)
import qualified XMonad.StackSet as W

main :: IO ()
main = xmonad $ myConfig
    `additionalKeys`
    myKeys
    ++ workspaceKeyBindings

myConfig = def
  { modMask = mod4Mask
  , terminal   = "kitty"
  , layoutHook = myLayout
  , workspaces = myWorkspaces
  , logHook = updatePointer (0.5, 0.5) (0, 0)
  }

myLayout =
    lessBorders Screen $ ifWider 1080 regularLayout tallLayout
  where
    withFull l = simpleTabbed ||| l
    
    tallLayout =
        withFull $ Mirror tiled

    regularLayout =
        withFull tiled

    tiled   = Tall nmaster delta ratio
    nmaster = 1
    delta   = 3/100
    ratio   = 1/2

myXPConfig :: XPConfig
myXPConfig = def
    { position = Bottom
    , alwaysHighlight = True
    , searchPredicate = fuzzyMatch
    , sorter = fuzzySort
    , promptBorderWidth = 0
    }

myWorkspaces :: [WorkspaceId]
myWorkspaces =
     map show [0..9]
  ++ [ 'F' : show i | i <- [1..12] ]

myWorkspaceKeys :: [KeySym]
myWorkspaceKeys =
     [xK_0 .. xK_9]
  ++ [xK_F1 .. xK_F12]

workspaceKeyBindings :: [((KeyMask, KeySym), X ())]
workspaceKeyBindings =
  [ ((mask .|. mod4Mask, key), windows (action ws))
  | (ws, key) <- zip myWorkspaces myWorkspaceKeys
  , (action, mask) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ]

myKeys :: [((KeyMask, KeySym), X ())]
myKeys =
  [((mod1Mask, xK_Tab), cycleRecentNonEmptyWS [xK_Alt_L] xK_Tab xK_grave)
  , ((mod4Mask .|. shiftMask, xK_m), tagToEmptyWorkspace)
  , ((mod4Mask, xK_Print), spawn "spectacle --windowundercursor")
  , ((mod4Mask, xK_b), bringMenu)
  , ((mod4Mask, xK_f), windowPrompt myXPConfig Goto allWindows)
  , ((mod4Mask, xK_m), viewEmptyWorkspace)
  , ((mod4Mask, xK_o), swapNextScreen)
  , ((mod4Mask, xK_r), runOrRaisePrompt myXPConfig)
  ]
