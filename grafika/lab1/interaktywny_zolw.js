import Turtle from "./zolw.js";
let turtle = new Turtle(document.getElementById("mainCanvas"));
/*let fre = /(?:forward\s+)(\d+\.\d*\b|\d+\b)/i;
let lre = /(?:left\s+)(\d+\.\d*\b|\d+\b)/i;
let rre = /(?:right\s+)(\d+\.\d*\b|\d+\b)/i;
let cre = /(?:color\s+)(#[0-9a-f]{6}\b)/i;*/
let mre = /(forward|left|right)\s+(\d+\.\d*\b|\d+\b)|(color)\s+(#[0-9a-f]{6}\b)/i;

function command() {
    let text = document.getElementById("input").value;
    let found = mre.exec(text);
    if (found == null) {
        return;
    }
    switch (found[1]) {
        case "forward":
            turtle.forward(Number(found[2]));
            break;
        case "left":
            turtle.left(Number(found[2]));
            break;
        case "right":
            turtle.right(Number(found[2]));
            break;
        case "color":
            turtle.color(found[2]);
            break;
        default:
            console.log("something went wrong with regex");
    }
}