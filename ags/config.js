// export default (await import('./bar/main.js')).default;
import bar from "./bar/main.js";
const { Gio } = imports.gi;

const scss = `${App.configDir}/styles`
const css = `/tmp/style.css`
const scssCompileCmd = `sassc ${scss}/style.scss ${css}`

// if scss not compiled, compile it first
Utils.readFileAsync(css)
    .catch((err) => {
        console.warn("css file not exist, compiling");
        Utils.exec(scssCompileCmd)
    })
    .finally(() => {
        App.config({
            windows: [bar()],
        })
        App.resetCss()
        App.applyCss(css)
    })

Utils.monitorFile(
    // directory that contains the scss files
    scss,
    // reload function
    function (file, event) {
        // compile, reset, apply
        if (event == Gio.FileMonitorEvent.CHANGES_DONE_HINT) {
            Utils.exec(scssCompileCmd)
            App.resetCss()
            App.applyCss(css)
            console.log(`reload scss: ${scssCompileCmd}`);
        }
    }
)