const { Gtk, Pango } = imports.gi;

const date = Variable("", {
    // poll: [1000, 'date +"%Y/%m/%d %H:%M:%S"']
    poll: [1000, 'date +"%H:%M:%S"']
})

const clock = () => {
    return Widget.Label({
        classNames: ["text-container"],
        label: date.bind(),
        "width-request": 70,
        // setup: (self) => {
        //     self.set_size_request(70, -1)
        // }
    })
}


export default clock;