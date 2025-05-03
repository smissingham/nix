{
  mainUser,
  ...
}:
{

  home-manager.users.${mainUser.username} = {

    targets.darwin.keybindings = {
      # Remap Home / End keys to be correct
      "\UF729" = "moveToBeginningOfLine:"; # Home
      "\UF72B" = "moveToEndOfLine:"; # End
    };
  };
}
