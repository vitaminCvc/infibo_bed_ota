const otaWesternTranslations = <String, Map<String, String>>{
  'es_ES': {
    'ota_check_intro':
        'Consulta el software y el firmware publicados para este dispositivo.',
    'ota_last_checked': 'Última comprobación · @time',
    'ota_installed_label': 'Versión instalada',
    'ota_published_label': 'Versión publicada',
    'ota_status_current': 'Actualizado',
    'ota_up_to_date_button': 'Actualizado',
    'ota_status_available': 'Actualización disponible',
    'ota_status_pending': 'Esperando información de la versión',
    'ota_status_checking': 'Comprobando',
    'ota_status_connection': 'Conexión sin confirmar',
    'ota_status_same': 'Misma versión',
    'ota_status_older': 'Firmware anterior',
    'ota_release_unavailable':
        'La información de la versión no está disponible. Vuelve a buscar actualizaciones.',
    'ota_board_connection_hint':
        'No se ha podido leer la versión de la placa. Comprueba la alimentación y la conexión serie y vuelve a intentarlo.',
    'ota_power_hint':
        'Mantén el dispositivo conectado a la alimentación durante toda la actualización.',
    'ota_notes_open': 'Ver notas de la versión',
    'ota_notes_empty': 'No se han proporcionado notas de la versión.',
    'ota_notes_collapse': 'Ocultar notas de la versión',
    'ota_cancel_transfer': 'Cancelar transferencia',
    'ota_cancel_update': 'Cancelar actualización',
    'ota_download_hint':
        'El paquete descargado se verificará antes de instalarlo.',
    'ota_app_higher_installed':
        'La compilación instalada es más reciente que la publicada. No es necesario actualizar.',
    'ota_app_target_available':
        'El software de la pantalla seleccionado por el administrador está disponible para su instalación.',
    'ota_app_target_installed':
        'La compilación seleccionada por el administrador ya está instalada.',
    'ota_published': 'Versión publicada: @version',
    'ota_board_reinstall': 'Descargar y reinstalar',
    'ota_board_downgrade': 'Descargar e instalar versión anterior',
    'ota_board_same_available':
        'El firmware publicado tiene la misma versión. Se puede reinstalar manualmente.',
    'ota_board_lower_available':
        'El administrador ha seleccionado un firmware anterior. Confirma la compatibilidad antes de instalarlo.',
    'ota_board_target_available':
        'El firmware seleccionado por el administrador está disponible para su instalación.',
    'ota_board_manual_policy':
        'El administrador selecciona la versión de destino, que puede ser la misma o una anterior. La placa y el cargador de arranque deben admitirla. La coincidencia de versión por sí sola no confirma la reinstalación.',
    'ota_board_reinstall_unverified':
        'Transferencia y verificación completadas; la placa indica la misma versión. No se ha confirmado de forma independiente que se haya reinstalado realmente.',
    'ota_signature_mismatch':
        'El certificado de firma de la actualización no coincide con el de la aplicación instalada.',
    'ota_apk_invalid':
        'El APK no es válido o no corresponde a esta versión de la aplicación.',
    'ota_installer_unavailable':
        'Android no ha podido abrir el instalador de paquetes.',
    'ota_confirm_board': '¿Actualizar la placa principal?',
    'ota_board_hint':
        'El dispositivo debe estar inactivo. Mantén la alimentación conectada durante toda la transferencia e instalación.',
    'ota_board_transferring': 'Transfiriendo firmware a la placa…',
    'ota_board_verifying': 'Verificando el firmware en la placa…',
    'ota_board_installing':
        'Instalando firmware. No desconectes la alimentación.',
    'ota_board_reconnecting':
        'Reconectando y confirmando la versión de la placa…',
    'ota_board_success':
        'Versión de la placa principal confirmada. Actualización completada.',
    'ota_board_error': 'La placa ha rechazado la actualización (error @code).',
    'ota_protocol_unsupported':
        'Esta placa no admite el protocolo OTA esperado.',
    'ota_image_too_large':
        'El firmware supera el espacio disponible para la aplicación en la placa.',
    'ota_image_incompatible':
        'El firmware no corresponde a la dirección de memoria de la aplicación de la placa.',
    'ota_progress_invalid':
        'El progreso de recepción de la placa es incoherente.',
    'ota_transfer_failed':
        'La transferencia del firmware ha fallado. Comprueba la conexión serie.',
    'ota_firmware_unknown':
        'No se ha confirmado el resultado de la instalación. Mantén la alimentación conectada y vuelve a comprobar la versión.',
    'system_update': 'Actualización del sistema',
    'ota_app': 'Software de la pantalla',
    'ota_board': 'Firmware de la placa principal',
    'ota_current': 'Actual: @version',
    'ota_latest': 'Más reciente: @version',
    'ota_unknown': 'No disponible',
    'ota_check': 'Buscar actualizaciones',
    'ota_update': 'Descargar y actualizar',
    'ota_firmware_pending':
        'Integración de la actualización de la placa en curso',
    'ota_idle': 'Listo',
    'ota_checking': 'Buscando actualizaciones…',
    'ota_checking_device': 'Comprobando que el dispositivo esté inactivo…',
    'ota_downloading': 'Descargando actualización…',
    'ota_verifying': 'Verificando actualización…',
    'ota_opening_installer': 'Abriendo el instalador de Android…',
    'ota_install_requested':
        'Completa la instalación en Android y vuelve a abrir esta aplicación.',
    'ota_needs_permission':
        'Permite que esta aplicación instale actualizaciones y vuelve para continuar. Se reutilizarán las descargas verificadas.',
    'ota_permission': 'Permitir instalación',
    'ota_success': 'Versión instalada confirmada. Actualización completada.',
    'ota_install_not_completed':
        'La instalación no se ha completado. Puedes volver a intentarlo.',
    'ota_not_configured': 'El servicio de actualizaciones no está configurado.',
    'ota_invalid_manifest':
        'Los metadatos de la actualización no corresponden a este dispositivo o canal.',
    'ota_network_error':
        'No se puede descargar la actualización. Comprueba la red y vuelve a intentarlo.',
    'ota_file_invalid':
        'La verificación del archivo ha fallado. Se ha bloqueado la instalación.',
    'ota_storage_error':
        'No se puede guardar la actualización. Comprueba el almacenamiento disponible.',
    'ota_download_failed': 'La descarga de la actualización ha fallado.',
    'ota_busy': 'Hay otra actualización en curso.',
    'ota_cancelled': 'Actualización cancelada.',
    'ota_device_busy': 'Detén el dispositivo antes de actualizar.',
    'ota_device_unavailable':
        'No se puede confirmar que el dispositivo esté inactivo. Comprueba la conexión.',
    'ota_android_only':
        'Las actualizaciones están disponibles en la pantalla Android.',
    'ota_failed':
        'La actualización ha fallado. Comprueba la conexión y vuelve a intentarlo.',
    'ota_cancel': 'Cancelar descarga',
    'ota_later': 'Más tarde',
    'ota_confirm': 'Actualizar',
    'ota_confirm_app': '¿Actualizar el software de la pantalla?',
    'ota_confirm_hint':
        'El dispositivo debe estar inactivo. Android puede pedirte que confirmes la instalación. Mantén el dispositivo conectado a la alimentación.',
    'ota_available': 'Hay una nueva versión disponible.',
    'ota_latest_installed': 'Esta versión está actualizada.',
    'ota_no_release': 'No se ha publicado ninguna versión.',
    'ota_prompt': 'Hay otra versión publicada disponible',
    'ota_view': 'Ver actualizaciones',
    'ota_notes': 'Notas de la versión',
  },
  'pt_PT': {
    'ota_check_intro':
        'Consulte o software e o firmware publicados para este dispositivo.',
    'ota_last_checked': 'Última verificação · @time',
    'ota_installed_label': 'Versão instalada',
    'ota_published_label': 'Versão publicada',
    'ota_status_current': 'Atualizado',
    'ota_up_to_date_button': 'Atualizado',
    'ota_status_available': 'Atualização disponível',
    'ota_status_pending': 'A aguardar informações da versão',
    'ota_status_checking': 'A verificar',
    'ota_status_connection': 'Ligação por confirmar',
    'ota_status_same': 'Mesma versão',
    'ota_status_older': 'Firmware anterior',
    'ota_release_unavailable':
        'As informações da versão não estão disponíveis. Volte a procurar atualizações.',
    'ota_board_connection_hint':
        'Não foi possível ler a versão da placa. Verifique a alimentação e a ligação série e tente novamente.',
    'ota_power_hint':
        'Mantenha o dispositivo ligado à alimentação durante toda a atualização.',
    'ota_notes_open': 'Ver notas da versão',
    'ota_notes_empty': 'Não foram fornecidas notas da versão.',
    'ota_notes_collapse': 'Ocultar notas da versão',
    'ota_cancel_transfer': 'Cancelar transferência',
    'ota_cancel_update': 'Cancelar atualização',
    'ota_download_hint':
        'O pacote transferido será verificado antes da instalação.',
    'ota_app_higher_installed':
        'A compilação instalada é mais recente do que a publicada. Não é necessário atualizar.',
    'ota_app_target_available':
        'O software do ecrã selecionado pelo administrador está disponível para instalação.',
    'ota_app_target_installed':
        'A compilação selecionada pelo administrador já está instalada.',
    'ota_published': 'Versão publicada: @version',
    'ota_board_reinstall': 'Transferir e reinstalar',
    'ota_board_downgrade': 'Transferir e instalar versão anterior',
    'ota_board_same_available':
        'O firmware publicado tem a mesma versão. É possível reinstalá-lo manualmente.',
    'ota_board_lower_available':
        'O administrador selecionou um firmware anterior. Confirme a compatibilidade antes de o instalar.',
    'ota_board_target_available':
        'O firmware selecionado pelo administrador está disponível para instalação.',
    'ota_board_manual_policy':
        'O administrador seleciona a versão de destino, que pode ser a mesma ou uma anterior. É necessário suporte da placa e do carregador de arranque. A correspondência da versão, por si só, não confirma a reinstalação.',
    'ota_board_reinstall_unverified':
        'Transferência e verificação concluídas; a placa indica a mesma versão. A reinstalação efetiva não foi confirmada de forma independente.',
    'ota_signature_mismatch':
        'O certificado de assinatura da atualização não corresponde ao da aplicação instalada.',
    'ota_apk_invalid':
        'O APK é inválido ou não corresponde a esta versão da aplicação.',
    'ota_installer_unavailable':
        'O Android não conseguiu abrir o instalador de pacotes.',
    'ota_confirm_board': 'Atualizar a placa principal?',
    'ota_board_hint':
        'O dispositivo tem de estar inativo. Mantenha a alimentação ligada durante toda a transferência e instalação.',
    'ota_board_transferring': 'A enviar firmware para a placa…',
    'ota_board_verifying': 'A verificar o firmware na placa…',
    'ota_board_installing': 'A instalar firmware. Não desligue a alimentação.',
    'ota_board_reconnecting':
        'A restabelecer a ligação e a confirmar a versão da placa…',
    'ota_board_success':
        'Versão da placa principal confirmada. Atualização concluída.',
    'ota_board_error': 'A placa rejeitou a atualização (erro @code).',
    'ota_protocol_unsupported':
        'Esta placa não suporta o protocolo OTA esperado.',
    'ota_image_too_large':
        'O firmware excede o espaço disponível para a aplicação na placa.',
    'ota_image_incompatible':
        'O firmware não corresponde ao endereço de memória da aplicação da placa.',
    'ota_progress_invalid': 'O progresso de receção da placa é inconsistente.',
    'ota_transfer_failed':
        'A transferência do firmware falhou. Verifique a ligação série.',
    'ota_firmware_unknown':
        'O resultado da instalação não foi confirmado. Mantenha a alimentação ligada e volte a verificar a versão.',
    'system_update': 'Atualização do sistema',
    'ota_app': 'Software do ecrã',
    'ota_board': 'Firmware da placa principal',
    'ota_current': 'Atual: @version',
    'ota_latest': 'Mais recente: @version',
    'ota_unknown': 'Indisponível',
    'ota_check': 'Procurar atualizações',
    'ota_update': 'Transferir e atualizar',
    'ota_firmware_pending': 'Integração da atualização da placa em curso',
    'ota_idle': 'Pronto',
    'ota_checking': 'A procurar atualizações…',
    'ota_checking_device': 'A verificar se o dispositivo está inativo…',
    'ota_downloading': 'A transferir a atualização…',
    'ota_verifying': 'A verificar a atualização…',
    'ota_opening_installer': 'A abrir o instalador do Android…',
    'ota_install_requested':
        'Conclua a instalação no Android e volte a abrir esta aplicação.',
    'ota_needs_permission':
        'Permita que esta aplicação instale atualizações e regresse para continuar. As transferências verificadas serão reutilizadas.',
    'ota_permission': 'Permitir instalação',
    'ota_success': 'Versão instalada confirmada. Atualização concluída.',
    'ota_install_not_completed':
        'A instalação não foi concluída. Pode tentar novamente.',
    'ota_not_configured': 'O serviço de atualizações não está configurado.',
    'ota_invalid_manifest':
        'Os metadados da atualização não correspondem a este dispositivo ou canal.',
    'ota_network_error':
        'Não é possível transferir a atualização. Verifique a rede e tente novamente.',
    'ota_file_invalid':
        'A verificação do ficheiro falhou. A instalação foi bloqueada.',
    'ota_storage_error':
        'Não é possível guardar a atualização. Verifique o espaço de armazenamento disponível.',
    'ota_download_failed': 'A transferência da atualização falhou.',
    'ota_busy': 'Está em curso outra atualização.',
    'ota_cancelled': 'Atualização cancelada.',
    'ota_device_busy': 'Pare o dispositivo antes de atualizar.',
    'ota_device_unavailable':
        'Não é possível confirmar que o dispositivo está inativo. Verifique a ligação.',
    'ota_android_only': 'As atualizações estão disponíveis no ecrã Android.',
    'ota_failed':
        'A atualização falhou. Verifique a ligação e tente novamente.',
    'ota_cancel': 'Cancelar transferência',
    'ota_later': 'Mais tarde',
    'ota_confirm': 'Atualizar',
    'ota_confirm_app': 'Atualizar o software do ecrã?',
    'ota_confirm_hint':
        'O dispositivo tem de estar inativo. O Android pode pedir a confirmação da instalação. Mantenha o dispositivo ligado à alimentação.',
    'ota_available': 'Está disponível uma nova versão.',
    'ota_latest_installed': 'Esta versão está atualizada.',
    'ota_no_release': 'Ainda não foi publicada nenhuma versão.',
    'ota_prompt': 'Está disponível outra versão publicada',
    'ota_view': 'Ver atualizações',
    'ota_notes': 'Notas da versão',
  },
  'fr_FR': {
    'ota_check_intro':
        'Consultez les logiciels et micrologiciels publiés pour cet appareil.',
    'ota_last_checked': 'Dernière vérification · @time',
    'ota_installed_label': 'Version installée',
    'ota_published_label': 'Version publiée',
    'ota_status_current': 'À jour',
    'ota_up_to_date_button': 'À jour',
    'ota_status_available': 'Mise à jour disponible',
    'ota_status_pending': 'En attente des informations de version',
    'ota_status_checking': 'Vérification',
    'ota_status_connection': 'Connexion non confirmée',
    'ota_status_same': 'Même version',
    'ota_status_older': 'Micrologiciel antérieur',
    'ota_release_unavailable':
        'Les informations de version sont indisponibles. Recherchez à nouveau les mises à jour.',
    'ota_board_connection_hint':
        'Impossible de lire la version de la carte. Vérifiez l’alimentation et la connexion série, puis réessayez.',
    'ota_power_hint':
        'Maintenez l’appareil sous tension pendant toute la mise à jour.',
    'ota_notes_open': 'Voir les notes de version',
    'ota_notes_empty': 'Aucune note de version fournie.',
    'ota_notes_collapse': 'Masquer les notes de version',
    'ota_cancel_transfer': 'Annuler le transfert',
    'ota_cancel_update': 'Annuler la mise à jour',
    'ota_download_hint':
        'Le paquet téléchargé sera vérifié avant l’installation.',
    'ota_app_higher_installed':
        'La version installée est plus récente que la version publiée. Aucune mise à jour n’est nécessaire.',
    'ota_app_target_available':
        'Le logiciel de l’écran sélectionné par l’administrateur est disponible à l’installation.',
    'ota_app_target_installed':
        'La version sélectionnée par l’administrateur est déjà installée.',
    'ota_published': 'Version publiée : @version',
    'ota_board_reinstall': 'Télécharger et réinstaller',
    'ota_board_downgrade': 'Télécharger et installer la version antérieure',
    'ota_board_same_available':
        'Le micrologiciel publié correspond à cette version. Une réinstallation manuelle est possible.',
    'ota_board_lower_available':
        'L’administrateur a sélectionné un micrologiciel antérieur. Vérifiez la compatibilité avant de revenir à cette version.',
    'ota_board_target_available':
        'Le micrologiciel sélectionné par l’administrateur est disponible à l’installation.',
    'ota_board_manual_policy':
        'L’administrateur choisit la version cible, y compris la même version ou une version antérieure. La carte et le chargeur d’amorçage doivent la prendre en charge. La seule correspondance de version ne confirme pas la réinstallation.',
    'ota_board_reinstall_unverified':
        'Transfert et vérification terminés ; la carte indique la même version. La réinstallation effective n’a pas été confirmée de manière indépendante.',
    'ota_signature_mismatch':
        'Le certificat de signature de la mise à jour ne correspond pas à celui de l’application installée.',
    'ota_apk_invalid':
        'Le fichier APK est invalide ou ne correspond pas à cette version de l’application.',
    'ota_installer_unavailable':
        'Android n’a pas pu ouvrir le programme d’installation de paquets.',
    'ota_confirm_board': 'Mettre à jour la carte principale ?',
    'ota_board_hint':
        'L’appareil doit être au repos. Maintenez l’alimentation pendant tout le transfert et l’installation.',
    'ota_board_transferring': 'Transfert du micrologiciel vers la carte…',
    'ota_board_verifying': 'Vérification du micrologiciel sur la carte…',
    'ota_board_installing':
        'Installation du micrologiciel. Ne coupez pas l’alimentation.',
    'ota_board_reconnecting':
        'Reconnexion et confirmation de la version de la carte…',
    'ota_board_success':
        'Version de la carte principale confirmée. Mise à jour terminée.',
    'ota_board_error': 'La carte a refusé la mise à jour (erreur @code).',
    'ota_protocol_unsupported':
        'Cette carte ne prend pas en charge le protocole OTA attendu.',
    'ota_image_too_large':
        'Le micrologiciel dépasse l’espace réservé à l’application sur la carte.',
    'ota_image_incompatible':
        'Le micrologiciel ne correspond pas à l’adresse mémoire de l’application de la carte.',
    'ota_progress_invalid':
        'La progression de la réception sur la carte est incohérente.',
    'ota_transfer_failed':
        'Le transfert du micrologiciel a échoué. Vérifiez la connexion série.',
    'ota_firmware_unknown':
        'Le résultat de l’installation n’est pas confirmé. Maintenez l’alimentation et vérifiez à nouveau la version.',
    'system_update': 'Mise à jour du système',
    'ota_app': 'Logiciel de l’écran',
    'ota_board': 'Micrologiciel de la carte principale',
    'ota_current': 'Actuelle : @version',
    'ota_latest': 'Dernière : @version',
    'ota_unknown': 'Indisponible',
    'ota_check': 'Rechercher des mises à jour',
    'ota_update': 'Télécharger et mettre à jour',
    'ota_firmware_pending':
        'Intégration de la mise à jour de la carte en cours',
    'ota_idle': 'Prêt',
    'ota_checking': 'Recherche de mises à jour…',
    'ota_checking_device': 'Vérification que l’appareil est au repos…',
    'ota_downloading': 'Téléchargement de la mise à jour…',
    'ota_verifying': 'Vérification de la mise à jour…',
    'ota_opening_installer': 'Ouverture du programme d’installation Android…',
    'ota_install_requested':
        'Terminez l’installation dans Android, puis rouvrez cette application.',
    'ota_needs_permission':
        'Autorisez cette application à installer des mises à jour, puis revenez pour continuer. Les téléchargements vérifiés seront réutilisés.',
    'ota_permission': 'Autoriser l’installation',
    'ota_success': 'Version installée confirmée. Mise à jour terminée.',
    'ota_install_not_completed':
        'L’installation n’est pas terminée. Vous pouvez réessayer.',
    'ota_not_configured': 'Le service de mise à jour n’est pas configuré.',
    'ota_invalid_manifest':
        'Les métadonnées de mise à jour ne correspondent pas à cet appareil ou à ce canal.',
    'ota_network_error':
        'Impossible de télécharger la mise à jour. Vérifiez le réseau et réessayez.',
    'ota_file_invalid':
        'La vérification du fichier a échoué. L’installation a été bloquée.',
    'ota_storage_error':
        'Impossible d’enregistrer la mise à jour. Vérifiez l’espace de stockage disponible.',
    'ota_download_failed': 'Le téléchargement de la mise à jour a échoué.',
    'ota_busy': 'Une autre mise à jour est en cours.',
    'ota_cancelled': 'Mise à jour annulée.',
    'ota_device_busy': 'Arrêtez l’appareil avant la mise à jour.',
    'ota_device_unavailable':
        'Impossible de confirmer que l’appareil est au repos. Vérifiez la connexion.',
    'ota_android_only':
        'Les mises à jour sont disponibles sur l’écran Android.',
    'ota_failed':
        'La mise à jour a échoué. Vérifiez la connexion et réessayez.',
    'ota_cancel': 'Annuler le téléchargement',
    'ota_later': 'Plus tard',
    'ota_confirm': 'Mettre à jour',
    'ota_confirm_app': 'Mettre à jour le logiciel de l’écran ?',
    'ota_confirm_hint':
        'L’appareil doit être au repos. Android peut demander de confirmer l’installation. Maintenez l’appareil sous tension.',
    'ota_available': 'Une nouvelle version est disponible.',
    'ota_latest_installed': 'Cette version est à jour.',
    'ota_no_release': 'Aucune version n’a été publiée.',
    'ota_prompt': 'Une autre version publiée est disponible',
    'ota_view': 'Voir les mises à jour',
    'ota_notes': 'Notes de version',
  },
  'de_DE': {
    'ota_check_intro':
        'Veröffentlichte Software und Firmware für dieses Gerät prüfen.',
    'ota_last_checked': 'Zuletzt geprüft · @time',
    'ota_installed_label': 'Installierte Version',
    'ota_published_label': 'Veröffentlichte Version',
    'ota_status_current': 'Aktuell',
    'ota_up_to_date_button': 'Aktuell',
    'ota_status_available': 'Update verfügbar',
    'ota_status_pending': 'Versionsinformationen ausstehend',
    'ota_status_checking': 'Wird geprüft',
    'ota_status_connection': 'Verbindung unbestätigt',
    'ota_status_same': 'Gleiche Version',
    'ota_status_older': 'Ältere Firmware',
    'ota_release_unavailable':
        'Versionsinformationen sind nicht verfügbar. Suchen Sie erneut nach Updates.',
    'ota_board_connection_hint':
        'Die Platinenversion konnte nicht gelesen werden. Prüfen Sie die Stromversorgung und die serielle Verbindung und versuchen Sie es erneut.',
    'ota_power_hint':
        'Lassen Sie das Gerät während des gesamten Updates an der Stromversorgung angeschlossen.',
    'ota_notes_open': 'Versionshinweise anzeigen',
    'ota_notes_empty': 'Keine Versionshinweise vorhanden.',
    'ota_notes_collapse': 'Versionshinweise ausblenden',
    'ota_cancel_transfer': 'Übertragung abbrechen',
    'ota_cancel_update': 'Update abbrechen',
    'ota_download_hint':
        'Das heruntergeladene Paket wird vor der Installation überprüft.',
    'ota_app_higher_installed':
        'Der installierte Build ist neuer als der veröffentlichte Build. Ein Update ist nicht erforderlich.',
    'ota_app_target_available':
        'Die vom Administrator ausgewählte Bildschirmsoftware kann installiert werden.',
    'ota_app_target_installed':
        'Der vom Administrator ausgewählte Build ist bereits installiert.',
    'ota_published': 'Derzeit veröffentlicht: @version',
    'ota_board_reinstall': 'Herunterladen und neu installieren',
    'ota_board_downgrade': 'Ältere Version herunterladen und installieren',
    'ota_board_same_available':
        'Die veröffentlichte Firmware entspricht dieser Version. Eine manuelle Neuinstallation ist möglich.',
    'ota_board_lower_available':
        'Der Administrator hat eine ältere Firmware ausgewählt. Prüfen Sie vor dem Zurückstufen die Kompatibilität.',
    'ota_board_target_available':
        'Die vom Administrator ausgewählte Firmware kann installiert werden.',
    'ota_board_manual_policy':
        'Der Administrator wählt die Zielversion aus, auch dieselbe oder eine ältere Version. Platine und Bootloader müssen dies unterstützen. Eine übereinstimmende Versionsnummer allein bestätigt keine Neuinstallation.',
    'ota_board_reinstall_unverified':
        'Übertragung und Überprüfung abgeschlossen; die Platine meldet dieselbe Version. Die tatsächliche Neuinstallation wurde nicht unabhängig bestätigt.',
    'ota_signature_mismatch':
        'Das Signaturzertifikat des Updates stimmt nicht mit dem der installierten App überein.',
    'ota_apk_invalid':
        'Die APK ist ungültig oder passt nicht zu dieser App-Version.',
    'ota_installer_unavailable':
        'Android konnte das Paketinstallationsprogramm nicht öffnen.',
    'ota_confirm_board': 'Hauptplatine aktualisieren?',
    'ota_board_hint':
        'Das Gerät muss im Leerlauf sein. Lassen Sie die Stromversorgung während der gesamten Übertragung und Installation angeschlossen.',
    'ota_board_transferring': 'Firmware wird auf die Platine übertragen…',
    'ota_board_verifying': 'Firmware auf der Platine wird überprüft…',
    'ota_board_installing':
        'Firmware wird installiert. Stromversorgung nicht trennen.',
    'ota_board_reconnecting':
        'Verbindung wird wiederhergestellt und Platinenversion bestätigt…',
    'ota_board_success':
        'Version der Hauptplatine bestätigt. Update abgeschlossen.',
    'ota_board_error': 'Die Platine hat das Update abgelehnt (Fehler @code).',
    'ota_protocol_unsupported':
        'Diese Platine unterstützt das erwartete OTA-Protokoll nicht.',
    'ota_image_too_large':
        'Die Firmware überschreitet den Anwendungsspeicher der Platine.',
    'ota_image_incompatible':
        'Die Firmware passt nicht zur Speicheradresse der Anwendung auf der Platine.',
    'ota_progress_invalid':
        'Der Empfangsfortschritt der Platine ist inkonsistent.',
    'ota_transfer_failed':
        'Firmwareübertragung fehlgeschlagen. Prüfen Sie die serielle Verbindung.',
    'ota_firmware_unknown':
        'Das Installationsergebnis ist nicht bestätigt. Lassen Sie die Stromversorgung eingeschaltet und prüfen Sie die Version erneut.',
    'system_update': 'Systemupdate',
    'ota_app': 'Bildschirmsoftware',
    'ota_board': 'Firmware der Hauptplatine',
    'ota_current': 'Aktuell: @version',
    'ota_latest': 'Neueste: @version',
    'ota_unknown': 'Nicht verfügbar',
    'ota_check': 'Nach Updates suchen',
    'ota_update': 'Herunterladen und aktualisieren',
    'ota_firmware_pending': 'Die Updatefunktion der Platine wird integriert',
    'ota_idle': 'Bereit',
    'ota_checking': 'Updates werden gesucht…',
    'ota_checking_device': 'Leerlauf des Geräts wird geprüft…',
    'ota_downloading': 'Update wird heruntergeladen…',
    'ota_verifying': 'Update wird überprüft…',
    'ota_opening_installer': 'Android-Installationsprogramm wird geöffnet…',
    'ota_install_requested':
        'Schließen Sie die Installation in Android ab und öffnen Sie diese App erneut.',
    'ota_needs_permission':
        'Erlauben Sie dieser App die Installation von Updates und kehren Sie dann zurück, um fortzufahren. Überprüfte Downloads werden wiederverwendet.',
    'ota_permission': 'Installation erlauben',
    'ota_success': 'Installierte Version bestätigt. Update abgeschlossen.',
    'ota_install_not_completed':
        'Die Installation ist noch nicht abgeschlossen. Sie können es erneut versuchen.',
    'ota_not_configured': 'Der Updatedienst ist nicht konfiguriert.',
    'ota_invalid_manifest':
        'Die Update-Metadaten passen nicht zu diesem Gerät oder Veröffentlichungskanal.',
    'ota_network_error':
        'Das Update kann nicht heruntergeladen werden. Prüfen Sie das Netzwerk und versuchen Sie es erneut.',
    'ota_file_invalid':
        'Dateiüberprüfung fehlgeschlagen. Die Installation wurde blockiert.',
    'ota_storage_error':
        'Das Update kann nicht gespeichert werden. Prüfen Sie den verfügbaren Speicherplatz.',
    'ota_download_failed': 'Download des Updates fehlgeschlagen.',
    'ota_busy': 'Ein anderes Update wird bereits ausgeführt.',
    'ota_cancelled': 'Update abgebrochen.',
    'ota_device_busy': 'Stoppen Sie das Gerät vor dem Update.',
    'ota_device_unavailable':
        'Der Leerlauf des Geräts kann nicht bestätigt werden. Prüfen Sie die Verbindung.',
    'ota_android_only': 'Updates sind auf dem Android-Bildschirm verfügbar.',
    'ota_failed':
        'Update fehlgeschlagen. Prüfen Sie die Verbindung und versuchen Sie es erneut.',
    'ota_cancel': 'Download abbrechen',
    'ota_later': 'Später',
    'ota_confirm': 'Aktualisieren',
    'ota_confirm_app': 'Bildschirmsoftware aktualisieren?',
    'ota_confirm_hint':
        'Das Gerät muss im Leerlauf sein. Android fordert Sie möglicherweise zur Bestätigung der Installation auf. Lassen Sie das Gerät an der Stromversorgung angeschlossen.',
    'ota_available': 'Eine neue Version ist verfügbar.',
    'ota_latest_installed': 'Diese Version ist aktuell.',
    'ota_no_release': 'Es wurde noch keine Version veröffentlicht.',
    'ota_prompt': 'Eine andere veröffentlichte Version ist verfügbar',
    'ota_view': 'Updates anzeigen',
    'ota_notes': 'Versionshinweise',
  },
};
