{{flutter_js}}
{{flutter_build_config}}

(() => {
  const bootStatus = () => document.getElementById('numuw-boot-status');

  function showBootError(error) {
    console.error('Numuw web bootstrap failed', error);
    const status = bootStatus();
    if (!status) return;
    status.classList.add('is-error');
    status.innerHTML = '<strong>تعذر تشغيل نُمُوّ</strong><span>حدّثي الصفحة مرة أخرى. إذا استمرت المشكلة، افتحيها في نافذة خاصة.</span>';
  }

  async function clearLegacyFlutterServiceWorker() {
    if (!('serviceWorker' in navigator)) return true;

    try {
      const registrations = await navigator.serviceWorker.getRegistrations();
      const numuwRegistrations = registrations.filter((registration) => {
        try {
          return new URL(registration.scope).pathname.startsWith('/Numuw/');
        } catch (_) {
          return false;
        }
      });

      if (numuwRegistrations.length === 0) return true;

      await Promise.all(
        numuwRegistrations.map((registration) => registration.unregister()),
      );

      if (!sessionStorage.getItem('numuw-sw-cleared')) {
        sessionStorage.setItem('numuw-sw-cleared', '1');
        window.location.reload();
        return false;
      }
    } catch (error) {
      console.warn('Could not clear legacy Numuw service worker', error);
    }

    return true;
  }

  async function startNumuw() {
    const canStart = await clearLegacyFlutterServiceWorker();
    if (!canStart) return;

    const config = {
      canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).toString(),
      canvasKitVariant: 'full',
      canvasKitForceCpuOnly: true,
    };

    await _flutter.loader.load({
      config,
      onEntrypointLoaded: async (engineInitializer) => {
        try {
          const appRunner = await engineInitializer.initializeEngine(config);
          await appRunner.runApp();
          bootStatus()?.remove();
        } catch (error) {
          showBootError(error);
        }
      },
    });
  }

  startNumuw().catch(showBootError);
})();
