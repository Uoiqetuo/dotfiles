import { Gtk } from "ags/gtk4";
import { createPoll } from "ags/time";

export default function Clock() {
  const time = createPoll("", 1000, 'date +"%H:%M:%S"')

  return (
    <label label={time} halign={Gtk.Align.CENTER} cssClasses={["clock", "widget"]}/>
  )
}