
tinymce.init({
    selector: "textarea.tinymce",
    license_key: "gpl",
    promotion: false,
    language: currentLang,
    plugins: [
        "advlist", "anchor", "autolink", "code", "fullscreen", "help",
        "lists", "preview", "link", "charmap", 
        "searchreplace", "table", "visualblocks", "wordcount"
    ],
    menubar: false,
    toolbar: "undo redo styles | bold italic underline superscript subscript link | charmap | indent outdent | " +
        "alignleft aligncenter alignright alignjustify | bullist numlist table hr | code ",
    toolbar_mode: "wrap",
    resize: "both",
    entity_encoding: "raw",
    valid_elements: JSON.parse(window["MIR.WebConfig.Editor.TinyMCE.HTML.Elements"] || "{}"),
    convert_urls: false,
    verify_html: false
});
