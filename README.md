# remind.nvim

Remind allows you to setup reminders, from right inside the neovim. 

To setup a reminder, type 
`:Rem <your-reminder-message> <time-in-minues>`

Example
**`:Rem This is a reminder message 5`**

The above command will open up a reminder after 5 minutes. 
The reminder will be shown in a floating window. 
In case, neovim is closed before reaching the reminder time, 
the reminders will persist on disk, and will be shown the next time 
you open up neovim. Reminders are automatically deleted after they pop up on the screen. 



### Installation

To install via LazyVim, create `remind.lua` file under `lua/plugins` folder and add the following:

```
return {
    {
      "CoderParth/remind.nvim",
      priority = 1000, -- Make sure to load this before all the other start plugins.
      init = function()
        require 'rem'
      end,
    }
}
