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

// Penulisan config diantrekan: sed -i menulis ulang seluruh file, dua toggle bersamaan bisa saling menimpa
let writes = Promise.resolve();

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
		el.addEventListener("change", () => { writes = writes.then(async () => {
			const val = el.checked ? el.dataset.on : el.dataset.off;
			const { code } = await exec(`grep -q '^${key}=' ${CONFIG} && sed -i 's/^${key}=.*/${key}=${val}/' ${CONFIG} || echo '${key}=${val}' >> ${CONFIG}`);
			if (code !== 0) { el.checked = !el.checked; toast("Gagal menyimpan / failed to save"); return; }
			toast((window.i18n && i18n.getTranslation("brene_reboot_label")) || "Changes apply after reboot");
		}); });
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

// Router SideX (fade.js) menambah entri history tiap pindah halaman, termasuk tombol Main Menu,
// sehingga keluar WebUI butuh banyak swipe. Kembali ke menu utama = mundur satu langkah, bukan entri baru.
document.addEventListener("click", (ev) => {
	const a = ev.target.closest && ev.target.closest('a[href="index.html"]');
	if (!a || history.state === null) return; // di entri pertama (menu utama awal): biarkan router
	ev.preventDefault();
	ev.stopImmediatePropagation();
	history.back();
}, true);

// Isian uname WebUI SideX masuk mentah ke perintah shell dan config.sh: tolak karakter di luar nilai uname wajar
const UNAME_OK = /^[A-Za-z0-9 .:_+#()-]*$/;
document.addEventListener("click", (ev) => {
	if (!ev.target.closest || !ev.target.closest("#set_uname")) return;
	const bad = ["sus_uname", "sus_uname_build"].map((id) => document.getElementById(id)).find((el) => el && !UNAME_OK.test(el.value));
	if (!bad) return;
	ev.preventDefault();
	ev.stopImmediatePropagation();
	toast("Karakter tidak diizinkan / invalid characters: hanya huruf, angka, spasi, . : _ + # ( ) -");
}, true);

// Filter UID (pendamping HMA-OSS): tombol Perbarui dan Cek UID; perintah tetap, UID hanya angka
const PRIORITY = "/data/adb/modules/hybrid_susfs/priority_uid.sh";
function showPriority(text) { const out = document.getElementById("priority_output"); if (out) out.textContent = text; }
document.addEventListener("click", async (ev) => {
	const button = ev.target.closest && ev.target.closest("[data-priority-action]");
	if (!button || button.disabled) return;
	let cmd = `sh ${PRIORITY} apply`;
	if (button.dataset.priorityAction === "diagnose") {
		const uid = (document.getElementById("priority_uid") || {}).value || "";
		if (!/^[0-9]{1,6}$/.test(uid.trim())) { toast("UID harus angka / UID must be a number"); return; }
		cmd = `sh ${PRIORITY} diagnose ${Number(uid.trim())}`;
	}
	button.disabled = true;
	await writes; // tunggu toggle tersimpan dulu
	const { code, stdout } = await exec(`${cmd} 2>&1`);
	button.disabled = false;
	showPriority(stdout.trim());
	if (code !== 0) toast("Gagal, lihat keterangan / failed, see details");
});
// Saat halaman muncul: tampilkan status filter terakhir
new MutationObserver(() => {
	const out = document.getElementById("priority_output");
	if (out && !out.dataset.loaded) { out.dataset.loaded = "1"; exec("cat /data/adb/ksu/hybrid_susfs/priority_uid_status.txt").then((r) => r.code === 0 && showPriority(r.stdout.trim())); }
}).observe(document.documentElement, { childList: true, subtree: true });
