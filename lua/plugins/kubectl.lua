-- Browse/edit the cluster like the VS Code Kubernetes extension, but in a buffer.
-- Uses your kubeconfig, so you only see what your RBAC allows.
-- blink.download pulls the prebuilt Rust client for the checked-out release tag.
vim.pack.add({
	"https://github.com/saghen/blink.download",
	{ src = "https://github.com/Ramilito/kubectl.nvim", version = vim.version.range("2") },
})

-- Your access is namespace-scoped: a cluster-wide list (namespace = "All") comes back
-- Forbidden and renders as an empty view, so start from the kubeconfig context's
-- namespace instead. Switch at runtime with <C-n>; the choice is saved per context.
local function context_namespace()
	local ok, out = pcall(function()
		return vim
			.system({ "kubectl", "config", "view", "--minify", "-o", "jsonpath={..namespace}" }, { text = true })
			:wait(2000)
	end)
	local ns = (ok and out.code == 0) and vim.trim(out.stdout or "") or ""
	return ns ~= "" and ns or "default"
end

require("kubectl").setup({
	namespace = context_namespace(),
	auto_refresh = { enabled = true, interval = 3000 },
	logs = { prefix = true, timestamps = true, since = "15m" },
	float_size = { width = 0.9, height = 0.8, col = 10, row = 5 },
})

vim.keymap.set("n", "<leader>8", function()
	require("kubectl").toggle({ tab = true })
end, { desc = "Kubernetes (k8s) cluster view" })
