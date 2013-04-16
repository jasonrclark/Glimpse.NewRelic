glimpse.data.initMetadata({
    "resources": {
        "glimpse_client": "/glimpse/assets/javascripts/client.js",
        "glimpse_history": "/glimpse/history{&top}",
        "glimpse_logo": "/glimpse/assets/images/logo.png",
        "glimpse_metadata": "/glimpse/assets/javascripts/metadata.js",
        "glimpse_request": "/glimpse/request_info?request_id={requestId}{&callback}",
        "glimpse_sprite": "/glimpse/assets/images/sprite.png",

        // n=glimpse_popup require to convince glimpse client that we're a popup window!
        "glimpse_popup": "/glimpse/popup?n=glimpse_popup&request_id={requestId}",

        "glimpse_ajax": "/glimpse/ajax/NotImplemented",
        "glimpse_config": "/glimpse/config/NotImplemented",
        "glimpse_version_check": "/glimpse/version_check/NotImplemented"
    },
    "version": "1.2.0"
});
