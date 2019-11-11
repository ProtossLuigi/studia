class Turtle {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext("2d");
        this.x = 0;
        this.y = 0;
        this.angle = 0;
        this.minX = 0;
        this.maxX = 255;
        this.minY = 0;
        this.maxY = 255;
        this.ctx.strokeStyle = "#000000";
    }

    forward(steps) {
        if (steps === 0) {
            return;
        }
        console.log(typeof steps);
        let fromX = {val: this.x};
        let fromY = {val: this.y};
        let toX = {val: fromX.val + steps * Math.cos(this.angle * Math.PI / 180)};
        console.log(typeof toX.val);
        let toY = {val: fromY.val + steps * Math.sin(this.angle * Math.PI / 180)};
        this.x = toX.val;
        this.y = toY.val;

        /*let t;
        if (fromX < this.minX) {
            if (toX < this.minX) {
                return;
            } else {
                t = (toX - this.minX)/(toX - fromX);
                fromX = this.minX;
                fromY = toY - (toY - fromY) * t;
            }
        } else if (fromX > this.maxX) {
            if (toX > this.maxX) {
                return;
            } else {
                t = (toX - this.maxX)/(toX - fromX);
                fromX = this.maxX;
                fromY = toY - (toY - fromY) * t;
            }
        }
        if (toX < this.minX) {
            t = (fromX - this.minX)/(fromX - toX);
            toX = this.minX;
            toY = fromY - (fromY - toY) * t;
        } else if (toX > this.maxX) {
            t = (fromX - this.maxX)/(fromX - toX);
            toX = this.maxX;
            toY = fromY - (fromY - toY) * t;
        }
        if (fromY < this.minY) {
            if (toY < this.minY) {
                return;
            } else {
                t = (toY - this.minY)/(toX - fromX);
                fromX = this.minX;
                fromY = toY - (toY - fromY) * t;
            }
        } else if (fromX > this.maxX) {
            if (toX > this.maxX) {
                return;
            } else {
                t = (toX - this.maxX)/(toX - fromX);
                fromX = this.maxX;
                fromY = toY - (toY - fromY) * t;
            }
        }
        if (toX < this.minX) {
            t = (fromX - this.minX)/(fromX - toX);
            toX = this.minX;
            toY = fromY - (fromY - toY) * t;
        } else if (toX > this.maxX) {
            t = (fromX - this.maxX)/(fromX - toX);
            toX = this.maxX;
            toY = fromY - (fromY - toY) * t;
        }*/
        if (!this.confine(fromX,fromY,toX,toY)) {
            return;
        }
        if (!this.confine(fromY,fromX,toY,toX)) {
            return;
        }
        console.log(fromX.val, fromY.val);
        console.log(toX.val, toY.val);
        let screenFromX = this.canvas.width * (fromX.val - this.minX) / this.maxX;
        let screenFromY = this.canvas.height * (1 - (fromY.val - this.minY) / this.maxY);
        let screenToX = this.canvas.width * (toX.val - this.minX) / this.maxX;
        let screenToY = this.canvas.height * (1 - (toY.val - this.minY) / this.maxY);
        console.log(screenFromX, screenFromY, screenToX, screenToY);
        console.log(typeof toX.val);
        this.ctx.moveTo(this.canvas.width * (fromX.val - this.minX) / this.maxX, this.canvas.height * (1 - (fromY.val - this.minY) / this.maxY));
        this.ctx.lineTo(this.canvas.width * (toX.val - this.minX) / this.maxX, this.canvas.height * (1 - (toY.val - this.minY) / this.maxY));
        this.ctx.stroke();
    }

    left(angle) {
        this.angle += angle;
        if (Math.abs(this.angle) >= 360) {
            this.angle = this.angle % 360;
        }
        if (this.angle < 0) {
            this.angle += 360;
        }
    }

    right(angle) {
        this.left(-angle);
    }

    color(c) {
        this.ctx.beginPath();
        this.ctx.strokeStyle = c;
    }

    confine(fromX,fromY,toX,toY) {
        let t;
        if (fromX.val < this.minX) {
            if (toX.val < this.minX) {
                return false;
            } else {
                t = (toX.val - this.minX)/(toX.val - fromX.val);
                fromX.val = this.minX;
                fromY.val = toY.val - (toY.val - fromY.val) * t;
            }
        } else if (fromX.val > this.maxX) {
            if (toX.val > this.maxX) {
                return false;
            } else {
                t = (toX.val - this.maxX)/(toX.val - fromX.val);
                fromX.val = this.maxX;
                fromY.val = toY.val - (toY.val - fromY.val) * t;
            }
        }
        if (toX.val < this.minX) {
            t = (fromX.val - this.minX)/(fromX.val - toX.val);
            toX.val = this.minX;
            toY.val = fromY.val - (fromY.val - toY.val) * t;
        } else if (toX.val > this.maxX) {
            t = (fromX.val - this.maxX)/(fromX.val - toX.val);
            toX.val = this.maxX;
            toY.val = fromY.val - (fromY.val - toY.val) * t;
        }
        return true;
    }
}

export default Turtle;