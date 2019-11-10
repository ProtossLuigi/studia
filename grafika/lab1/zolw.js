class Turtle {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext("2d");
        this.x = 0;
        this.y = 0;
        this.angle = 0;
        this.ctx.moveTo(0, canvas.height);
    }

    forward(steps) {
        if (steps === 0) {
            return;
        }
        let deltaX = steps * Math.cos(this.angle * Math.PI / 180);
        let deltaY = steps * Math.sin(this.angle * Math.PI / 180);
        let t;
        if (this.x + deltaX < 0) {
            t = this.x/(-deltaX);
            deltaX = -this.x;
            deltaY *= t;
        }
        if (this.x + deltaX > 255) {
            t = (255-this.x)/deltaX;
            deltaX = 255-this.x;
            deltaY *= t;
        }
        if (this.y + deltaY < 0) {
            t = this.y/(-deltaY);
            deltaY = -this.y;
            deltaX *= t;
        }
        if (this.y + deltaY > 255) {
            t = (255-this.y)/deltaY;
            deltaY = 255-this.y;
            deltaX *= t;
        }
        this.ctx.lineTo(this.canvas.width * ((this.x+deltaX)/255), this.canvas.height * (1 - (this.y + deltaY)/255));
        this.ctx.stroke();
        this.x += deltaX;
        this.y += deltaY;
        this.ctx.moveTo(this.x,this.y);
    }

    left(angle) {
        this.angle += angle;
    }

    right(angle) {
        this.angle -= angle;
    }
}