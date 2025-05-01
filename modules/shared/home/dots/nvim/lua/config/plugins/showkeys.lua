return {
    {
	"nvzone/showkeys",
	cmd = "ShowkeysToggle",
	opts = {
	    timeout = 1,
	    maxkeys = 5,
	    show_count = true;
	},
	config = function()
	    --vim.cmd("ShowkeysToggle");
	end
    }
}
