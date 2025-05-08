document.addEventListener("DOMContentLoaded", () => {
    // Watch for dynamically generated map placeholders
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            mutation.addedNodes.forEach((node) => {
                if (node.classList && node.classList.contains("webr-map")) {
                    const tempDir = node.dataset.tempdir;
                    if (tempDir) {
                        loadMapFromTempDir(tempDir, node);
                    }
                }
            });
        });
    });

    // Start observing the body for added nodes
    observer.observe(document.body, { childList: true, subtree: true });
});

// Load and inline all dependencies
async function loadMapFromTempDir(tempDir, container) {
    try {
        const baseDir = `/tmp/${tempDir}/`;
        const indexFile = `${baseDir}/index.html`;
        
        // Fetch the main HTML file
        const response = await fetch(indexFile);
        let htmlContent = await response.text();

        // Replace CSS and JS references
        htmlContent = htmlContent.replace(/(?:href|src)="([^"]+)"/g, (match, filePath) => {
            const fullPath = `${baseDir}/${filePath}`;
            if (filePath.endsWith(".css")) {
                return `<style>${loadFileSync(fullPath)}</style>`;
            } else if (filePath.endsWith(".js")) {
                return `<script>${loadFileSync(fullPath)}</script>`;
            }
            return match;
        });

        // Set the inner HTML of the container
        container.innerHTML = htmlContent;
        container.style.border = "1px solid #ccc";
    } catch (error) {
        console.error("Failed to load map files:", error);
    }
}

// Synchronous file loading helper
function loadFileSync(filePath) {
    const xhr = new XMLHttpRequest();
    xhr.open("GET", filePath, false); // Synchronous call
    xhr.send();
    return xhr.responseText;
}