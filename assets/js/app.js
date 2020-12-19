// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"

let selectedSlots = {}

let Hooks = {}
Hooks.TimeSlots = {
    mounted() {
        const className = "events__time-slot"
        let slots = document.getElementsByClassName(className)
        let isDown = false

        for (let x = 0; x < slots.length; x++) {
            const slotDate = slots[x].getAttribute("phx-value-day")
            const slotId = slots[x].getAttribute("phx-value-id")
            const isSelectedSlot = slots[x].classList.contains("events__time-slot--active")

            if (isSelectedSlot) {
                updateDaySlots(slotDate, slotId)
            }

            slots[x].addEventListener("mousedown", (e) => {
                toggleSlot(e.target)

                isDown = true
            })

            slots[x].addEventListener("mouseenter", (e) => {
                if (isDown) {
                    const elem = e.target.closest(`.${className}`);

                    if (elem) {
                        toggleSlot(elem)
                    }
                }
            }, false)

            document.addEventListener("mouseup", (e) => {
                if (isDown) {
                    isDown = false

                    // Send list of selected slots to the server
                    this.pushEvent("update_time_slots", { "selected_slots": selectedSlots })
                }
            })
        }

        // Update local copy of selected slots.
        this.handleEvent("refresh_local_slots", ({ selected_slots }) => {
            selectedSlots = selected_slots
        })
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    params: { _csrf_token: csrfToken },
    hooks: Hooks,
})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Toggles a slot, and updates `selectedSlots` accordingly.
function toggleSlot(slotEl) {
    slotEl.classList.toggle("bg-green-200")

    const isSelected = slotEl.classList.contains("bg-green-200")
    const index = slotEl.getAttribute("phx-value-id")
    const day = slotEl.getAttribute("phx-value-day")
    const slot = slotEl.getAttribute("phx-value-slot")
    const slotVal = { "day": day, "slot": slot, "index": index }

    // Check if the new toggled state is selected.
    if (isSelected) {
        updateDaySlots(day, index)

    } else {
        const ndx = selectedSlots[day].findIndex((el, index) => {
            el == index
        })

        if (ndx > -1) {
            selectedSlots[day][ndx].splice(ndx, 1)
        }
    }
}

// Update local copy of selected slots.
function updateDaySlots(date, slotId) {
    if (date in selectedSlots) {
        selectedSlots[date].push(slotId)
    } else {
        selectedSlots[date] = [slotId]
    }
}