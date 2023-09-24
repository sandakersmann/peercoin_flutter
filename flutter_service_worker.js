'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "c4abd4e7d2bd46b59e84cd33c7f016b6",
"splash/img/light-2x.png": "0406724cfad97ca88d46dfac0340e48c",
"splash/img/dark-4x.png": "3dbea66ebb7a3302e8dcae4fc8c9d8a4",
"splash/img/light-3x.png": "863fff472ecfa710700cde74a4f4bd11",
"splash/img/dark-3x.png": "863fff472ecfa710700cde74a4f4bd11",
"splash/img/light-4x.png": "3dbea66ebb7a3302e8dcae4fc8c9d8a4",
"splash/img/dark-2x.png": "0406724cfad97ca88d46dfac0340e48c",
"splash/img/dark-1x.png": "cee13247444b1493e230450ac7f2f3ba",
"splash/img/light-1x.png": "cee13247444b1493e230450ac7f2f3ba",
"splash/splash.js": "123c400b58bea74c1305ca3ac966748d",
"splash/style.css": "2e6df68c18efc965e0beb1b72c5b4ae9",
"favicon.ico": "ad86c3b942b739addeee37dae114ade7",
"index.html": "73723003bc112ec0df7866e57db2c374",
"/": "73723003bc112ec0df7866e57db2c374",
"main.dart.js": "eb7d90b25e274b0dc4e42f569fb6a12e",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"icons/Icon-192.png": "d8ed4418b7e314bca062868e82748e9f",
"icons/Icon-512.png": "2b839693a7a9604f2bde0cd67fd17abc",
"manifest.json": "10413e652ec1368443e68e96fa0b876f",
"assets/CHANGELOG.md": "ae220a71475cb47ab929b230fefd65ed",
"assets/AssetManifest.json": "9d6b78f863af2be92d0cdcf322a56c78",
"assets/NOTICES": "00e0d92507c0849a4610dfbd35ebfb17",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/AssetManifest.bin": "14de2c63eb470cec041f1cdaccd90674",
"assets/fonts/MaterialIcons-Regular.otf": "684bfb32c4ff85e42a2ff4f198291c07",
"assets/assets/img/setup-legal.png": "a5f0f4ec17060446a8f22f0aa143b3be",
"assets/assets/img/setup-consent.png": "11a73f79fff6cdd2f64a78793dcd0c32",
"assets/assets/img/setup-security.png": "0e38cf5b064c7559b1ca5f64fbd6e608",
"assets/assets/img/setup-protection.png": "7d1b5c326c6d648364d48c4d4c30c15d",
"assets/assets/img/list-empty.png": "0385368cc21600608a7f0c8ede129882",
"assets/assets/icon/ppc-icon-256.png": "e5893fe49cc40e589885c69aa6e8a1ed",
"assets/assets/icon/ppc-icon-48.png": "77a7f5e9cfab4965c9e356ade1087fde",
"assets/assets/icon/ppc-logo.png": "d564432a5793345b243bb4afcefd2611",
"assets/assets/icon/ppc-icon-white-48.png": "4cc5c9b1858468267167e5a9ec3ff62d",
"assets/assets/icon/ppc-icon-white-256.png": "817576d10026737e3423c39c05e1eed1",
"assets/assets/icon/ppc-icon-48-grey.png": "7db13d2026075562d5a2e3d8aed09c6e",
"assets/assets/icon/ppc-ios-app-xxl.png": "457ede70c42d9f8acc53d9e3c91137a2",
"assets/assets/icon/ppc-icon.png": "1614470da6cab032cc9afd1bad8ddbb3",
"assets/assets/icon/ppc-icon-white-bg.png": "60d7216eaee21cc15e50b2cea455a0c3",
"assets/assets/icon/ppc-icon-white.png": "96dc88b95eba378109c756e2e469ee1c",
"assets/assets/translations/hy.json": "82d935835daf1464bb6b1e7b42ada788",
"assets/assets/translations/zh.json": "e4aaa5a7eede65747eff85652d6d117a",
"assets/assets/translations/ps.json": "e67f4fcef6edd1e820e82bea4f554b57",
"assets/assets/translations/tr.json": "15ca9b05d9d080306a5846d847622845",
"assets/assets/translations/or.json": "116d5c8762400ae06141ef7a9db3d9e9",
"assets/assets/translations/mk.json": "ffc6836ae7b4198b40f81663649c4db1",
"assets/assets/translations/sl.json": "90ad8b18e10193fbe89d951d006af200",
"assets/assets/translations/hu.json": "cf0092abe9120a2a0f443e70f5bcc580",
"assets/assets/translations/mr.json": "8943e0a806cc55a24fe07e199785423f",
"assets/assets/translations/lt.json": "5d7d9258fab9307962711cec57a9a516",
"assets/assets/translations/is.json": "f5933004e8ac60878129f1ab2c1e23b5",
"assets/assets/translations/ha.json": "d0b91a5b4e57c90338c580f512f653ee",
"assets/assets/translations/kk.json": "37642f98f305065a379c3f08d00f1d48",
"assets/assets/translations/nl.json": "f0167e639c5c611e7aa3796d0f17627b",
"assets/assets/translations/ms.json": "f02d1df08a6e7f78b2ca5d9ed159cc15",
"assets/assets/translations/ja.json": "f699952b1f573fbcc7e858ab555d5b58",
"assets/assets/translations/de.json": "da929a75e3c2b0c0506d14191e6d00cf",
"assets/assets/translations/ru.json": "89b1f238bde411efa081a9a46e5288c5",
"assets/assets/translations/pl.json": "5ed8e6eeff8c7c7e90bb01073994f9f3",
"assets/assets/translations/uk.json": "703766f166bf7fd7c0403652434bb424",
"assets/assets/translations/gsw.json": "b2d0aa2675177da76457566f8cfa699a",
"assets/assets/translations/ky.json": "c14021697300f1832251b7f34f4c4214",
"assets/assets/translations/fi.json": "3d404db8250b98c70351117729af3be4",
"assets/assets/translations/ta.json": "4ce71d5b65132146028508e861563f5e",
"assets/assets/translations/fil.json": "1d0ff52200d117bcd061eb4f18e7eb87",
"assets/assets/translations/ur.json": "908132a45fa9abf55116d991e6c7aba5",
"assets/assets/translations/sk.json": "91ba537b9c6020b7d5cda08507a114d9",
"assets/assets/translations/ml.json": "ead10a2b8f90019ba248437a122f068c",
"assets/assets/translations/az.json": "db50181244573d1b6ffe577df430b3e6",
"assets/assets/translations/pt.json": "4e3f47ad4b25fa8d523f271859fbd376",
"assets/assets/translations/be.json": "49490d8a0f2502268e053b614cea357c",
"assets/assets/translations/en.json": "62e683d109c9936dd5871bae862826fd",
"assets/assets/translations/ka.json": "5e9a1e00925adc9eefd9222dd8395a51",
"assets/assets/translations/pa.json": "307e103d3b276fc390f4a5840cdb12fa",
"assets/assets/translations/my.json": "bad2911dcaafbc9c6433e90001506836",
"assets/assets/translations/km.json": "f9f5cab48dfe3cb1d412fee3106fb1a3",
"assets/assets/translations/it.json": "76b9ceb4e1fcc1718ced94e45ddfed04",
"assets/assets/translations/sr.json": "25955d3c1615e4e05dc7a6c7d9499ed3",
"assets/assets/translations/hr.json": "776dcc2ac41a6eaa7589e84fc3200638",
"assets/assets/translations/tl.json": "6fd1675eff21cebc5692a9ec956b2bb8",
"assets/assets/translations/zu.json": "aea18cee1a5bbe2386d394a866474324",
"assets/assets/translations/et.json": "272cb102a55332551a83c07b08bb32f9",
"assets/assets/translations/kn.json": "49e827734ddbb4039f84203902f997ff",
"assets/assets/translations/cy.json": "9f9feeb42effec1ba51aa8e08496ee9e",
"assets/assets/translations/sq.json": "4e730499303a0b8034c196f7185abdb0",
"assets/assets/translations/ne.json": "09ec96618c81954631861b55abbf3240",
"assets/assets/translations/bs.json": "d402647147e3084611d84d76933da3e5",
"assets/assets/translations/fr.json": "7c24f71632d6de1c144800993c9e5a24",
"assets/assets/translations/am.json": "0a7cf587e82a0e826e85f49a084e0c09",
"assets/assets/translations/gu.json": "d82437f4360ffecdef69a5f8cd5fd5e8",
"assets/assets/translations/el.json": "4c02562ca3aef7f9dbabfa0b6fa565b4",
"assets/assets/translations/bg.json": "f129dcf365f2045bead6ddc5d2c28099",
"assets/assets/translations/ro.json": "84ba302e24edb30eaa420145079472ae",
"assets/assets/translations/hi.json": "f71f92503581d974979bf6564d9b4fc5",
"assets/assets/translations/ca.json": "dbde7064adfe78cf7d4b13e0177eba5e",
"assets/assets/translations/mn.json": "703524ed9725aeb6ab577ec40d0f9a17",
"assets/assets/translations/si.json": "f49e75dfc48137733b028ef953bf582f",
"assets/assets/translations/ko.json": "b646c15587c8d628bbc3ba78ba5666f8",
"assets/assets/translations/eu.json": "c929c0c5a7de6091fef0bf5ece7c415a",
"assets/assets/translations/gl.json": "37bd4a8a331ce6584a4f28b07d585357",
"assets/assets/translations/he.json": "dd15fd1d42b714b8c988ec30b3d99cbd",
"assets/assets/translations/vi.json": "c06d666f76a9e0ac81dec6237e16b651",
"assets/assets/translations/nb_NO.json": "8423219ae6abf32af349768f5bd987d0",
"assets/assets/translations/fa.json": "b7502d0e667c30b070e5b55c65a82fda",
"assets/assets/translations/lo.json": "e86d3779675a86ef8f7c09585addb651",
"assets/assets/translations/cs.json": "6291652f1d9af9381638ba83a2066a9c",
"assets/assets/translations/te.json": "86becb2823a9c7bddd3156f3a4fb9b6d",
"assets/assets/translations/as.json": "4091e5b41fdc0950d69e1b98c2c99e13",
"assets/assets/translations/zh_Hant.json": "6b5b94224c7865b48dbf7aeb004737de",
"assets/assets/translations/id.json": "b960c6b7186ed3d8c89692f08c1e17ca",
"assets/assets/translations/uz.json": "8f1d713ba9d8d0b5b4947d5ff1e58355",
"assets/assets/translations/bn_BD.json": "c9d74a68e64f0f2be2f819b2a5c0bfe0",
"assets/assets/translations/lv.json": "49d1a16f2620080547f15d9647aa24d6",
"assets/assets/translations/af.json": "80bffae3ca202f1c3f57f464999c078d",
"assets/assets/translations/sw.json": "48031a8831502384952997d74bd190eb",
"assets/assets/translations/da.json": "f5f1c5e3cbf64520644be81adfcf280c",
"assets/assets/translations/th.json": "c55d97fb446efcd8fa1235b0303adc1b",
"assets/assets/translations/sv.json": "b93b1a1a031dd7c5c261e645009b0eb9",
"assets/assets/translations/es.json": "7561058f0d52bfb44707e7cb46a38def",
"assets/assets/translations/ar.json": "8c66a015e10e96866104b3bfcbf24e1c",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "d1fde2560be92c0b07ad9cf9acb10d05",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/chromium/canvaskit.wasm": "1165572f59d51e963a5bf9bdda61e39b",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/canvaskit.wasm": "19d8b35640d13140fe4e6f3b8d450f04",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
