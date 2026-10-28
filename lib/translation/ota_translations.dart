const _en = <String, String>{
  'ota_check_intro': 'Check published software and firmware for this device.',
  'ota_last_checked': 'Last checked · @time',
  'ota_installed_label': 'Installed version',
  'ota_published_label': 'Published version',
  'ota_status_current': 'Up to date',
  'ota_up_to_date_button': 'Up to date',
  'ota_status_available': 'Update available',
  'ota_status_pending': 'Awaiting release info',
  'ota_status_checking': 'Checking',
  'ota_status_connection': 'Connection unconfirmed',
  'ota_status_same': 'Same version',
  'ota_status_older': 'Older firmware',
  'ota_release_unavailable':
      'Release information is unavailable. Check updates again.',
  'ota_board_connection_hint':
      'Board version could not be read. Check power and the serial connection, then check again.',
  'ota_power_hint': 'Keep the device powered throughout the update.',
  'ota_notes_open': 'View release notes',
  'ota_notes_empty': 'No release notes provided.',
  'ota_notes_collapse': 'Hide release notes',
  'ota_cancel_transfer': 'Cancel Transfer',
  'ota_cancel_update': 'Cancel Update',
  'ota_download_hint':
      'The downloaded package is verified before installation.',
  'ota_app_higher_installed':
      'The installed build is newer than the published build. No update is needed.',

  'ota_app_target_available':
      'The administrator-selected screen software is available to install.',
  'ota_app_target_installed':
      'The administrator-selected build is already installed.',

  'ota_published': 'Currently published: @version',
  'ota_board_reinstall': 'Download and Reinstall',
  'ota_board_downgrade': 'Download and Downgrade',
  'ota_board_same_available':
      'The published firmware matches this version. Manual reinstallation is available.',
  'ota_board_lower_available':
      'The administrator selected an older firmware. Confirm compatibility before downgrading.',
  'ota_board_target_available':
      'The administrator-selected firmware is available to install.',
  'ota_board_manual_policy':
      'The administrator selects the target, including the same or an older version. Board and Bootloader support is required. A matching version alone cannot verify reinstallation.',
  'ota_board_reinstall_unverified':
      'Transfer and verification completed; the board responds with the same version. Actual reinstallation is not independently confirmed.',
  'ota_signature_mismatch':
      'Update signing certificate does not match the installed app.',
  'ota_apk_invalid': 'The APK is invalid or does not match this app version.',
  'ota_installer_unavailable': 'Android could not open the package installer.',
  'ota_confirm_board': 'Upgrade main board?',
  'ota_board_hint':
      'The device must be idle. Keep power connected throughout transfer and installation.',
  'ota_board_transferring': 'Transferring firmware to the board…',
  'ota_board_verifying': 'Checking firmware on the board…',
  'ota_board_installing': 'Installing firmware. Do not disconnect power.',
  'ota_board_reconnecting': 'Reconnecting and confirming board version…',
  'ota_board_success': 'Main board version confirmed. Upgrade complete.',
  'ota_board_error': 'Board rejected the upgrade (error @code).',
  'ota_protocol_unsupported':
      'This board does not support the expected OTA protocol.',
  'ota_image_too_large': 'Firmware exceeds the board application space.',
  'ota_image_incompatible':
      'Firmware does not match the board application address.',
  'ota_progress_invalid': 'Board receive progress is inconsistent.',
  'ota_transfer_failed':
      'Firmware transfer failed. Check the serial connection.',
  'ota_firmware_unknown':
      'Installation result is not confirmed. Keep power on and check the version again.',
  'system_update': 'System Update',
  'ota_app': 'Screen Software',
  'ota_board': 'Main Board Firmware',
  'ota_current': 'Current: @version',
  'ota_latest': 'Latest: @version',
  'ota_unknown': 'Unavailable',
  'ota_check': 'Check Updates',
  'ota_update': 'Download and Update',
  'ota_firmware_pending': 'Board upgrade is being connected',
  'ota_idle': 'Ready',
  'ota_checking': 'Checking updates…',
  'ota_checking_device': 'Checking device is idle…',
  'ota_downloading': 'Downloading update…',
  'ota_verifying': 'Verifying update…',
  'ota_opening_installer': 'Opening Android installer…',
  'ota_install_requested':
      'Complete installation in Android, then reopen this app.',
  'ota_needs_permission':
      'Allow this app to install updates, then return to continue. Verified downloads will be reused.',
  'ota_permission': 'Allow Installation',
  'ota_success': 'Installed version confirmed. Update complete.',
  'ota_install_not_completed':
      'Installation has not completed. You can try again.',
  'ota_not_configured': 'Update service has not been configured.',
  'ota_invalid_manifest':
      'Update metadata does not match this device or channel.',
  'ota_network_error':
      'Cannot download the update. Check the network and retry.',
  'ota_file_invalid': 'File verification failed. Installation was blocked.',
  'ota_storage_error': 'Cannot save the update. Check available storage.',
  'ota_download_failed': 'Update download failed.',
  'ota_busy': 'Another update is in progress.',
  'ota_cancelled': 'Update cancelled.',
  'ota_device_busy': 'Stop the device before updating.',
  'ota_device_unavailable':
      'Cannot confirm the device is idle. Check the connection.',
  'ota_android_only': 'Updates are available on the Android screen.',
  'ota_failed': 'Update failed. Check the connection and retry.',
  'ota_cancel': 'Cancel Download',
  'ota_later': 'Later',
  'ota_confirm': 'Update',
  'ota_confirm_app': 'Update screen software?',
  'ota_confirm_hint':
      'The device must be idle. Android may ask you to confirm installation. Keep the device powered.',
  'ota_available': 'A new version is available.',
  'ota_latest_installed': 'This version is up to date.',
  'ota_no_release': 'No release has been published.',
  'ota_prompt': 'A different published version is available',
  'ota_view': 'View Updates',
  'ota_notes': 'Release notes',
};
const _zh = <String, String>{
  'ota_check_intro': '查看本设备的软件与主板固件发布信息。',
  'ota_last_checked': '上次检查 · @time',
  'ota_installed_label': '已安装版本',
  'ota_published_label': '当前发布版本',
  'ota_status_current': '无需更新',
  'ota_up_to_date_button': '已是最新版本',
  'ota_status_available': '有可用更新',
  'ota_status_pending': '待获取发布信息',
  'ota_status_checking': '检查中',
  'ota_status_connection': '连接待确认',
  'ota_status_same': '相同版本',
  'ota_status_older': '较低版本固件',
  'ota_release_unavailable': '暂未取得发布信息，请重新检查更新。',
  'ota_board_connection_hint': '未读取到主板版本，请检查供电和串口连接后重新检查。',
  'ota_power_hint': '更新期间请保持设备供电。',
  'ota_notes_open': '查看更新说明',
  'ota_notes_empty': '暂无更新说明。',
  'ota_notes_collapse': '收起更新说明',
  'ota_cancel_transfer': '取消传输',
  'ota_cancel_update': '取消更新',
  'ota_download_hint': '下载完成后将校验安装包，再进行安装。',
  'ota_app_higher_installed': '当前版本高于发布版本，无需更新。',

  'ota_app_target_available': '可安装管理员当前指定的上位机软件。',
  'ota_app_target_installed': '已安装管理员当前指定的版本编号。',

  'ota_published': '当前发布：@version',
  'ota_board_reinstall': '下载并重新安装',
  'ota_board_downgrade': '下载并降级安装',
  'ota_board_same_available': '当前发布与主板版本相同，可以手动重新安装。',
  'ota_board_lower_available': '管理员指定了较低版本，确认固件兼容后可降级安装。',
  'ota_board_target_available': '可安装管理员当前指定的固件版本。',
  'ota_board_manual_policy':
      '安装目标由管理员选择，可同版本重装或降级，仍需主板和 Bootloader 支持。同版本回读不能单独证明重新安装成功。',
  'ota_board_reinstall_unverified': '传输和校验完成，主板已响应相同版本；尚不能独立确认是否真正重新安装。',
  'ota_signature_mismatch': '升级包签名与已安装软件不一致，无法覆盖升级。',
  'ota_apk_invalid': 'APK 文件非法或与当前软件版本不匹配。',
  'ota_installer_unavailable': '安卓系统未能打开安装程序。',
  'ota_confirm_board': '确认升级主板？',
  'ota_board_hint': '设备须处于空闲状态，传输和安装期间请勿断电。',
  'ota_board_transferring': '正在向主板传输固件…',
  'ota_board_verifying': '正在校验主板缓存…',
  'ota_board_installing': '正在安装主板固件，请勿断电。',
  'ota_board_reconnecting': '正在重新连接并确认主板版本…',
  'ota_board_success': '已确认主板版本，升级成功。',
  'ota_board_error': '主板拒绝升级，错误码 @code。',
  'ota_protocol_unsupported': '主板不支持当前 OTA 协议。',
  'ota_image_too_large': '固件超过主板可用程序空间。',
  'ota_image_incompatible': '固件与主板程序起始地址不匹配。',
  'ota_progress_invalid': '主板接收进度异常。',
  'ota_transfer_failed': '固件传输失败，请检查串口连接。',
  'ota_firmware_unknown': '尚未确认安装结果，请保持供电，稍后重新检查主板版本。',
  'system_update': '系统更新',
  'ota_app': '上位机软件',
  'ota_board': '主板固件',
  'ota_current': '当前版本：@version',
  'ota_latest': '最新版本：@version',
  'ota_unknown': '暂不可用',
  'ota_check': '检查更新',
  'ota_update': '下载并更新',
  'ota_firmware_pending': '主板升级正在接入',
  'ota_idle': '就绪',
  'ota_checking': '正在检查更新…',
  'ota_checking_device': '正在确认设备空闲…',
  'ota_downloading': '正在下载升级包…',
  'ota_verifying': '正在校验升级包…',
  'ota_opening_installer': '正在打开安卓安装程序…',
  'ota_install_requested': '请在安卓系统中完成安装，然后重新打开软件。',
  'ota_needs_permission': '请允许本软件安装更新，返回后继续；已校验的安装包会直接复用。',
  'ota_permission': '允许安装更新',
  'ota_success': '已确认安装版本，升级成功。',
  'ota_install_not_completed': '安装尚未完成，可以再次尝试。',
  'ota_not_configured': '尚未配置升级服务器。',
  'ota_invalid_manifest': '升级信息与当前设备或发布渠道不匹配。',
  'ota_network_error': '无法下载更新，请检查网络后重试。',
  'ota_file_invalid': '文件校验失败，已阻止安装。',
  'ota_storage_error': '无法保存升级包，请检查剩余存储空间。',
  'ota_download_failed': '升级包下载失败。',
  'ota_busy': '已有升级任务正在进行。',
  'ota_cancelled': '已取消升级。',
  'ota_device_busy': '请先结束设备运行，再进行升级。',
  'ota_device_unavailable': '无法确认设备空闲，请检查主板连接。',
  'ota_android_only': '升级功能请在安卓屏上使用。',
  'ota_failed': '升级失败，请检查连接后重试。',
  'ota_cancel': '取消下载',
  'ota_later': '稍后',
  'ota_confirm': '更新',
  'ota_confirm_app': '确认更新软件？',
  'ota_confirm_hint': '设备须处于空闲状态。安卓系统可能要求确认安装，请保持设备供电。',
  'ota_available': '发现新版本。',
  'ota_latest_installed': '当前已是最新版本。',
  'ota_no_release': '暂未发布更新。',
  'ota_prompt': '当前发布版本与设备版本不同',
  'ota_view': '查看更新',
  'ota_notes': '更新说明',
};
const _pl = <String, String>{
  'ota_check_intro':
      'Sprawdź opublikowane oprogramowanie i firmware dla tego urządzenia.',
  'ota_last_checked': 'Ostatnio sprawdzono · @time',
  'ota_installed_label': 'Zainstalowana wersja',
  'ota_published_label': 'Opublikowana wersja',
  'ota_status_current': 'Aktualna',
  'ota_up_to_date_button': 'Aktualna',
  'ota_status_available': 'Dostępna aktualizacja',
  'ota_status_pending': 'Oczekiwanie na informacje o wydaniu',
  'ota_status_checking': 'Sprawdzanie',
  'ota_status_connection': 'Połączenie niepotwierdzone',
  'ota_status_same': 'Ta sama wersja',
  'ota_status_older': 'Starszy firmware',
  'ota_release_unavailable':
      'Informacje o wydaniu są niedostępne. Sprawdź aktualizacje ponownie.',
  'ota_board_connection_hint':
      'Nie udało się odczytać wersji płyty głównej. Sprawdź zasilanie i połączenie szeregowe, a następnie spróbuj ponownie.',
  'ota_power_hint': 'Nie odłączaj zasilania podczas aktualizacji.',
  'ota_notes_open': 'Pokaż opis zmian',
  'ota_notes_empty': 'Brak opisu zmian.',
  'ota_notes_collapse': 'Ukryj opis zmian',
  'ota_cancel_transfer': 'Anuluj przesyłanie',
  'ota_cancel_update': 'Anuluj aktualizację',
  'ota_download_hint': 'Pobrany pakiet zostanie sprawdzony przed instalacją.',
  'ota_app_higher_installed':
      'Zainstalowana kompilacja jest nowsza od opublikowanej. Aktualizacja nie jest potrzebna.',
  'ota_app_target_available':
      'Oprogramowanie ekranu wybrane przez administratora jest dostępne do instalacji.',
  'ota_app_target_installed':
      'Kompilacja wybrana przez administratora jest już zainstalowana.',
  'ota_published': 'Obecnie opublikowana: @version',
  'ota_board_reinstall': 'Pobierz i zainstaluj ponownie',
  'ota_board_downgrade': 'Pobierz i zainstaluj starszą wersję',
  'ota_board_same_available':
      'Opublikowany firmware ma tę samą wersję. Możliwa jest ręczna ponowna instalacja.',
  'ota_board_lower_available':
      'Administrator wybrał starszy firmware. Przed instalacją potwierdź zgodność.',
  'ota_board_target_available':
      'Wersja firmware wybrana przez administratora jest dostępna do instalacji.',
  'ota_board_manual_policy':
      'Administrator wybiera wersję docelową, także tę samą lub starszą. Wymagane jest wsparcie płyty głównej i programu rozruchowego. Zgodność numeru wersji nie potwierdza ponownej instalacji.',
  'ota_board_reinstall_unverified':
      'Przesyłanie i weryfikacja zakończone. Płyta główna zgłasza tę samą wersję. Faktyczna ponowna instalacja nie została niezależnie potwierdzona.',
  'ota_signature_mismatch':
      'Certyfikat podpisu aktualizacji nie odpowiada zainstalowanej aplikacji.',
  'ota_apk_invalid':
      'Plik APK jest nieprawidłowy lub nie pasuje do wersji aplikacji.',
  'ota_installer_unavailable':
      'Android nie mógł otworzyć instalatora pakietów.',
  'ota_confirm_board': 'Zaktualizować płytę główną?',
  'ota_board_hint':
      'Urządzenie musi być bezczynne. Nie odłączaj zasilania podczas przesyłania i instalacji.',
  'ota_board_transferring': 'Przesyłanie firmware do płyty głównej…',
  'ota_board_verifying': 'Weryfikacja firmware na płycie głównej…',
  'ota_board_installing': 'Instalowanie firmware. Nie odłączaj zasilania.',
  'ota_board_reconnecting':
      'Ponowne łączenie i potwierdzanie wersji płyty głównej…',
  'ota_board_success':
      'Wersja płyty głównej potwierdzona. Aktualizacja zakończona.',
  'ota_board_error': 'Płyta główna odrzuciła aktualizację (błąd @code).',
  'ota_protocol_unsupported':
      'Ta płyta główna nie obsługuje wymaganego protokołu OTA.',
  'ota_image_too_large':
      'Firmware przekracza dostępną pamięć programu płyty głównej.',
  'ota_image_incompatible':
      'Firmware nie pasuje do adresu programu płyty głównej.',
  'ota_progress_invalid': 'Nieprawidłowy postęp odbioru na płycie głównej.',
  'ota_transfer_failed':
      'Przesyłanie firmware nie powiodło się. Sprawdź połączenie szeregowe.',
  'ota_firmware_unknown':
      'Wynik instalacji nie został potwierdzony. Nie odłączaj zasilania i sprawdź wersję ponownie.',
  'system_update': 'Aktualizacja systemu',
  'ota_app': 'Oprogramowanie ekranu',
  'ota_board': 'Firmware płyty głównej',
  'ota_current': 'Bieżąca: @version',
  'ota_latest': 'Najnowsza: @version',
  'ota_unknown': 'Niedostępne',
  'ota_check': 'Sprawdź aktualizacje',
  'ota_update': 'Pobierz i zaktualizuj',
  'ota_firmware_pending': 'Trwa wdrażanie obsługi aktualizacji płyty głównej',
  'ota_idle': 'Gotowe',
  'ota_checking': 'Sprawdzanie aktualizacji…',
  'ota_checking_device': 'Sprawdzanie, czy urządzenie jest bezczynne…',
  'ota_downloading': 'Pobieranie aktualizacji…',
  'ota_verifying': 'Weryfikacja aktualizacji…',
  'ota_opening_installer': 'Otwieranie instalatora Android…',
  'ota_install_requested':
      'Dokończ instalację w systemie Android, a następnie otwórz aplikację ponownie.',
  'ota_needs_permission':
      'Zezwól aplikacji na instalowanie aktualizacji i wróć, aby kontynuować. Zweryfikowane pliki zostaną użyte ponownie.',
  'ota_permission': 'Zezwól na instalację',
  'ota_success': 'Zainstalowana wersja potwierdzona. Aktualizacja zakończona.',
  'ota_install_not_completed':
      'Instalacja nie została zakończona. Możesz spróbować ponownie.',
  'ota_not_configured': 'Usługa aktualizacji nie została skonfigurowana.',
  'ota_invalid_manifest':
      'Informacje o aktualizacji nie pasują do urządzenia lub kanału dystrybucji.',
  'ota_network_error':
      'Nie można pobrać aktualizacji. Sprawdź sieć i spróbuj ponownie.',
  'ota_file_invalid':
      'Weryfikacja pliku nie powiodła się. Instalacja została zablokowana.',
  'ota_storage_error':
      'Nie można zapisać aktualizacji. Sprawdź wolne miejsce w pamięci.',
  'ota_download_failed': 'Pobieranie aktualizacji nie powiodło się.',
  'ota_busy': 'Trwa już inna aktualizacja.',
  'ota_cancelled': 'Aktualizacja anulowana.',
  'ota_device_busy': 'Zatrzymaj urządzenie przed aktualizacją.',
  'ota_device_unavailable':
      'Nie można potwierdzić, że urządzenie jest bezczynne. Sprawdź połączenie.',
  'ota_android_only': 'Aktualizacje są dostępne na ekranie z systemem Android.',
  'ota_failed':
      'Aktualizacja nie powiodła się. Sprawdź połączenie i spróbuj ponownie.',
  'ota_cancel': 'Anuluj pobieranie',
  'ota_later': 'Później',
  'ota_confirm': 'Aktualizuj',
  'ota_confirm_app': 'Zaktualizować oprogramowanie ekranu?',
  'ota_confirm_hint':
      'Urządzenie musi być bezczynne. Android może poprosić o potwierdzenie instalacji. Nie odłączaj zasilania.',
  'ota_available': 'Dostępna jest nowa wersja.',
  'ota_latest_installed': 'Ta wersja jest aktualna.',
  'ota_no_release': 'Nie opublikowano jeszcze aktualizacji.',
  'ota_prompt': 'Dostępna jest inna opublikowana wersja',
  'ota_view': 'Pokaż aktualizacje',
  'ota_notes': 'Opis zmian',
};

Map<String, Map<String, String>> withOtaTranslations(
  Map<String, Map<String, String>> existing,
) => {
  for (final entry in existing.entries)
    entry.key: {
      ...entry.value,
      ..._en,
      if (entry.key == 'zh_CN') ..._zh,
      if (entry.key == 'pl_PL') ..._pl,
    },
};
