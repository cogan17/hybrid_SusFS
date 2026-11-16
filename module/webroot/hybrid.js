// Hybrid SusFS: toggle Brene (input[data-brene]) <-> /data/adb/hybrid_susfs/config.sh
const CONFIG = "/data/adb/hybrid_susfs/config.sh";
let seq = 0;

function exec(cmd) {
	return new Promise((resolve) => {
		const cb = `hybrid_cb_${Date.now()}_${seq++}`;
		window[cb] = (code, stdout) => { delete window[cb]; resolve({ code, stdout: stdout || "" }); };
		try { ksu.exec(cmd, "{}", cb); } catch (e) { delete window[cb]; resolve({ code: 1, stdout: "" }); }
	});
}

function toast(msg) { try { ksu.toast(msg); } catch (e) {} }

async function bind(inputs) {
	const { stdout } = await exec(`cat ${CONFIG}`);
	const cfg = {};
	for (const line of stdout.split("\n")) {
		const m = line.match(/^([A-Za-z0-9_]+)=(.*)$/);
		if (m) cfg[m[1]] = m[2].replace(/^'|'$/g, "");
	}
	for (const el of inputs) {
		const key = el.dataset.brene;
		el.checked = cfg[key] === el.dataset.on;
		el.addEventListener("change", async () => {
			const val = el.checked ? el.dataset.on : el.dataset.off;
			const { code } = await exec(`grep -q '^${key}=' ${CONFIG} && sed -i 's/^${key}=.*/${key}=${val}/' ${CONFIG} || echo '${key}=${val}' >> ${CONFIG}`);
			if (code !== 0) { el.checked = !el.checked; toast("Gagal menyimpan / failed to save"); return; }
			toast((window.i18n && i18n.getTranslation("brene_reboot_label")) || "Changes apply after reboot");
		});
	}
}

// Halaman diganti router (data-router-view), jadi ikat input baru setiap kali muncul
function scan() {
	const fresh = [...document.querySelectorAll("input[data-brene]:not([data-bound])")];
	if (!fresh.length) return;
	fresh.forEach((el) => el.setAttribute("data-bound", ""));
	bind(fresh);
}
new MutationObserver(scan).observe(document.documentElement, { childList: true, subtree: true });
scan();

// Perintah baca WebUI yang gagal (dicatat di assets/index-*.js) ditampilkan sekali, sebagai bukti untuk laporan bug
setTimeout(() => {
	const failed = [...new Set(window.hybridFailed || [])];
	if (failed.length) toast(`hybrid_susfs: ${failed.length} perintah gagal: ${failed.slice(0, 3).join(" | ")}`);
}, 5000);
