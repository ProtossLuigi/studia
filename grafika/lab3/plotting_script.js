let VertGLSL = `
attribute vec3 coords;
attribute vec3 normals;

uniform vec3 transform;
uniform mat4 projection;
uniform mat4 rotation;
uniform vec3 move;

varying vec3 vcoords;
varying vec3 vnormals;
varying vec4 vpos;

void main(void) {
    vcoords = coords;
    vnormals = normals;

    vpos = rotation * vec4(coords + transform, 1.0) + vec4(move, 0.0);
    gl_Position =  projection * vpos;
}
`;

// fragment shader
let FragGLSL = `
precision highp float;

uniform float fog;
uniform vec3 ambient;
uniform float strength;
uniform int diffuse;

varying vec3 vcoords;
varying vec3 vnormals;
varying vec4 vpos;

// fix colors to rgb
vec3 hsv2rgb(float h, float s, float v) {
    vec4 K = vec4(1., 2. / 3., 1. / 3., 3.);
    vec3 p = abs(fract(h + K.xyz) * 6. - K.www);
    return v * mix(K.xxx, clamp(p - K.xxx, 0., 1.), s);
}

void main(void) {
    /* color */
    vec3 rgb = hsv2rgb(vcoords.y, 1., 1.);
    vec3 bgcol = vec3(0.5, 0.5, 0.5);
    vec3 col;
    if (fog != -1.) {
        col = mix(rgb, bgcol, clamp(abs(vpos.z) / (200. - fog * 3.), 0., 1.));
    } else {
        col = rgb;
    }

    /* lightning */
    vec3 lightDirection = vec3(1, 1, 1);
    vec3 ambc = strength * ambient;
    col = ambc * col;

    if (diffuse != 0) {
        col *= clamp(dot(-lightDirection, vnormals), 0.0, 1.0);
    }
    gl_FragColor = vec4(col, 1.);
}
`;

let canvas = document.querySelector('#mainCanvas');
let gl = canvas.getContext('webgl');
let fInput = document.querySelector('#fInput');
let xMinInput = document.querySelector('#xMin');
let xMaxInput = document.querySelector('#xMax');
let yMinInput = document.querySelector('#yMin');
let yMaxInput = document.querySelector('#yMax');

let textureCoordBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, textureCoordBuffer);
let textureCoordinates = [ 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0 ];
gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(textureCoordinates), gl.STATIC_DRAW);

// graphical plot graphPlotect to draw
class GraphicalPlot {
    constructor(verts, norms, x = 0, y = 0, z = 0, r = 1, g = 1, b = 1) {
        this.x = x;
        this.y = y;
        this.z = z;

        this.verts = verts;
        this.norms = norms;

        this.vertBuf = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertBuf);
        gl.bufferData(gl.ARRAY_BUFFER, this.verts, gl.STATIC_DRAW);

        this.normBuf = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, this.normBuf);
        gl.bufferData(gl.ARRAY_BUFFER, this.norms, gl.STATIC_DRAW);
        gl.bindBuffer(gl.ARRAY_BUFFER, null);
    }

    // draw graphical graphPlotect
    draw() {
        gl.useProgram(program);

        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertBuf);
        let coords = gl.getAttribLocation(program, 'coords');
        gl.vertexAttribPointer(coords, 3, gl.FLOAT, false, 0, 0);
        gl.enableVertexAttribArray(coords);

        gl.bindBuffer(gl.ARRAY_BUFFER, this.normBuf);
        let normals = gl.getAttribLocation(program, 'normals');
        gl.vertexAttribPointer(normals, 3, gl.FLOAT, false, 0, 0);
        gl.enableVertexAttribArray(normals);

        gl.uniform3f(gl.getUniformLocation(program, 'transform'), this.x, this.y, this.z);

        let projectionLocation = gl.getUniformLocation(program, "projection");
        let rotationLocation = gl.getUniformLocation(program, "rotation");
        let moveLocation = gl.getUniformLocation(program, "move");

        gl.uniformMatrix4fv(rotationLocation, false, rotationMatrix);
        gl.uniform3fv(moveLocation, moveVector);
        gl.uniformMatrix4fv(projectionLocation, false, projectionMatrix);

        gl.uniform1f(gl.getUniformLocation(program, "fog"), fogLevel);

        gl.uniform3f(gl.getUniformLocation(program, 'ambient'), ...ambient);
        gl.uniform1f(gl.getUniformLocation(program, "strength"), strength);
        gl.uniform1i(gl.getUniformLocation(program, "diffuse"), diffuse << 0);

        gl.drawArrays(gl[DrawStyles[drawStyle]], 0, this.verts.length / 3);
    }

    destroy() {
        gl.deleteBuffer(this.vertBuf);
    }
}

// compile vertex shader
let vertShader = gl.createShader(gl.VERTEX_SHADER);
gl.shaderSource(vertShader, VertGLSL);
gl.compileShader(vertShader);
if (!gl.getShaderParameter(vertShader, gl.COMPILE_STATUS)) {
    console.error("VERT COMPILE ERROR:\n", gl.getShaderInfoLog(vertShader));
}

// compile fragment shader
let fragShader = gl.createShader(gl.FRAGMENT_SHADER);
gl.shaderSource(fragShader, FragGLSL);
gl.compileShader(fragShader);
if (!gl.getShaderParameter(fragShader, gl.COMPILE_STATUS)) {
    console.error("FRAG COMPILE ERROR:\n", gl.getShaderInfoLog(fragShader));
}

// create program
let program = gl.createProgram();
gl.attachShader(program, vertShader);
gl.attachShader(program, fragShader);
gl.linkProgram(program);
if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    console.error("LINK ERROR:\n", gl.getProgramInfoLog(program));
}

let f = (x, y) => 5 * Math.sin(x) + 5 * Math.sin(y); // default function
let rangeX = [ -3, 3 ]; // default range
let rangeY = [ -3, 3];
let graphPlot, projectionMatrix, rotationMatrix, fogLevel = 5; // defaults

let DrawStyles = [ "POINTS", "LINE_STRIP", "TRIANGLE_STRIP" ]; // drawing styles to select
let drawStyle = 2; // default style
let ambient = [ 1, 1, 1 ]; // default ambient
let strength = 2; // ambient strength
let diffuse = true; // default diffuse on

// operations on vector
let vec = {
    add : (v1, v2) => [v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2]],
    sub : (v1, v2) => [v1[0] - v2[0], v1[1] - v2[1], v1[2] - v2[2]],
    div : (v, d) => v.map(x => x / d),
    cross : (v1, v2) => [v1[1] * v2[2] - v1[2] * v2[1], v1[0] * v2[2] - v1[2] * v2[0], v1[0] * v2[1] - v1[1] * v2[0]],
    mag : v => Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]),
    norm : v => vec.div(v, vec.mag(v))
};

// draw new plot
function plotFunction() {
    let verts = [];
    let norms = [];

    function vert(x, y) {
        let stepX = (rangeX[1] - rangeX[0]) / 500;
        let stepY = (rangeY[1] - rangeY[0]) / 500;
        let xx = rangeX[0] + x * stepX;
        let yy = rangeY[0] + y * stepY;
        return [ x / 10, f(xx, yy), y / 10 ];
    }

    // calculate vaertices and norms
    for (let y = -250; y <= 250; y += 2) {
        for (let x = -250; x <= 250; x++) {
            let v1 = vert(x, y);
            let v2 = vert(x, y + 1);
            verts.push(...v1, ...v2);
        }
        for (let x = 250; x >= -250; x--) {
            v1 = vert(x, y + 2);
            v2 = vert(x, y + 1);
            verts.push(...v1, ...v2);
        }
    }

    for (let i = 0; i < verts.length; i += 3) {
        let p1 = [ verts[i + 0], verts[i + 1], verts[i + 2] ];
        let p2 = [ verts[i + 3], verts[i + 4], verts[i + 5] ];
        let p3 = [ verts[i + 6], verts[i + 7], verts[i + 8] ];

        let u = vec.sub(p2, p1);
        let v = vec.sub(p3, p1);
        let n = vec.cross(u, v);

        if (i % 2 == 1) {
            n = n.map(x => -x);
        }

        n = vec.norm(n);
        norms.push(...n);
    }

    // destroy existing graphical graphPlotect
    if (graphPlot) {
        graphPlot.destroy();
    }

    // create new graphical plot graphPlotect for drawing from vertices and norms
    graphPlot = new GraphicalPlot(new Float32Array(verts), new Float32Array(norms));
}

// draw whole plot and info
function draw() {
    gl.useProgram(program);
    projectionMatrix = glMatrix4FromMatrix(createProjectionMatrix4(gl, ProjectionZNear, ProjectionZFar, ProjectionZoomY));
    rotationMatrix = glMatrix4FromMatrix(rotationMatrix4); // tmp

    gl.clearColor(0.5, 0.5, 0.5, 1);
    gl.enable(gl.DEPTH_TEST);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.viewport(0, 0, canvas.width, canvas.height);

    graphPlot.draw();

    //updateInfo();
}

// update info about funciton
function updateParams() {
    let v = fInput.value;
    eval(`f = (x, y) => ${v};`);
    rangeX = [parseFloat(xMinInput.value),parseFloat(xMaxInput.value)];
    rangeY = [parseFloat(yMinInput.value),parseFloat(yMaxInput.value)];
    plotFunction();
}

let keyPressed = {up : false, down : false};

window.onkeydown = function(e) {
    let code = e.which || e.keyCode;
    let alpha = Math.PI / 32;
    switch (code) {
        case 13: {
            updateParams();
            break;
        }

        case 38: { // up
            rotationMatrix4 = matrix4RotatedYZ(rotationMatrix4, alpha);
            break;
        }

        case 40: { // down
            rotationMatrix4 = matrix4RotatedYZ(rotationMatrix4, -alpha);
            break;
        }

        case 37: { // left
            rotationMatrix4 = matrix4RotatedXZ(rotationMatrix4, -alpha);
            break;
        }

        case 39: { // right
            rotationMatrix4 = matrix4RotatedXZ(rotationMatrix4, alpha);
            break;
        }

        case 87: { // W
            moveVector[2]++;
            break;
        }

        case 83: { // S
            moveVector[2]--;
            break;
        }

        case 65: { // A
            moveVector[0]--;
            break;
        }

        case 68: { // D
            moveVector[0]++;
            break;
        }

        case 81: { // Q
            moveVector[1]--;
            break;
        }

        case 69: { // E
            moveVector[1]++;
            break;
        }

        case 32: { // space
            rotationMatrix4 = IdentityMatrix4;
            rotationMatrix4 = matrix4RotatedYZ(rotationMatrix4, -Math.PI / 16);
            if (e.ctrlKey) {
                fogLevel = -1;
                moveVector = [ 0, -2, 100 ];
            }
            break;
        }
    }
    draw();
};


// rotate from lecture
window.onresize = function() {
    let wth = parseInt(window.innerWidth) - 100;
    let hth = parseInt(window.innerHeight) - 100;
    canvas.setAttribute("width", '' + wth);
    canvas.setAttribute("height", '' + hth);
    gl.viewportWidth = wth;
    gl.viewportHeight = hth;
    gl.viewport(0, 0, wth, hth);
    draw();
};

window.onload = function() {
    plotFunction();
    rotationMatrix4 = matrix4RotatedYZ(rotationMatrix4, -Math.PI / 16);
    window.onresize();
};

const ProjectionZNear = 0.25;
const ProjectionZFar = 300;
const ProjectionZoomY = 4.0;

const IdentityMatrix4 = [
    [ 1, 0, 0, 0 ],
    [ 0, 1, 0, 0 ],
    [ 0, 0, 1, 0 ],
    [ 0, 0, 0, 1 ],
];

let rotationMatrix4 = IdentityMatrix4;

let moveVector = [ 0, -2, 100 ];

let createProjectionMatrix4 =
    function(gl, zNear, zFar, zoomY) {
        /* arguments:
           gl - GL context
           zNear, zFar, zoomY - Y-frustum parameters

           returns: 4x4 row-major order perspective matrix
           */
        let xx = zoomY * gl.viewportHeight / gl.viewportWidth;
        let yy = zoomY;
        let zz = (zFar + zNear) / (zFar - zNear);
        let zw = 1;
        let wz = -2 * zFar * zNear / (zFar - zNear);
        return [ [ xx, 0, 0, 0 ], [ 0, yy, 0, 0 ], [ 0, 0, zz, wz ], [ 0, 0, zw, 0 ] ];
    }

let glVector3 = function(x, y, z) {
    return new Float32Array(x, y, z);
};

let glMatrix4 = function(xx, yx, zx, wx, xy, yy, zy, wy, xz, yz, zz, wz, xw, yw, zw, ww) {
    // sequence of concatenated columns
    return new Float32Array([ xx, xy, xz, xw, yx, yy, yz, yw, zx, zy, zz, zw, wx, wy, wz, ww ]);
};

let glMatrix4FromMatrix = function(m) {
    /* arguments:
       m - the 4x4 array with the matrix in row-major order

       returns: sequence of elements in column-major order in Float32Array for GL
       */
    return glMatrix4(m[0][0], m[0][1], m[0][2], m[0][3], m[1][0], m[1][1], m[1][2], m[1][3], m[2][0], m[2][1], m[2][2], m[2][3], m[3][0], m[3][1], m[3][2], m[3][3]);
};

let scalarProduct4 = function(v, w) {
    return v[0] * w[0] + v[1] * w[1] + v[2] * w[2] + v[3] * w[3];
};

let matrix4Column = function(m, c) {
    return [ m[0][c], m[1][c], m[2][c], m[3][c] ];
};

let matrix4Product = function(m1, m2) {
    let sp = scalarProduct4;
    let col = matrix4Column;
    return [
        [ sp(m1[0], col(m2, 0)), sp(m1[0], col(m2, 1)), sp(m1[0], col(m2, 2)), sp(m1[0], col(m2, 3)) ], [ sp(m1[1], col(m2, 0)), sp(m1[1], col(m2, 1)), sp(m1[1], col(m2, 2)), sp(m1[1], col(m2, 3)) ],
        [ sp(m1[2], col(m2, 0)), sp(m1[2], col(m2, 1)), sp(m1[2], col(m2, 2)), sp(m1[1], col(m2, 3)) ], [ sp(m1[3], col(m2, 0)), sp(m1[3], col(m2, 1)), sp(m1[3], col(m2, 2)), sp(m1[3], col(m2, 3)) ]
    ];
};

let matrix4RotatedXZ = function(matrix, alpha) {
    let c = Math.cos(alpha);
    let s = Math.sin(alpha);
    let rot = [ [ c, 0, -s, 0 ], [ 0, 1, 0, 0 ], [ s, 0, c, 0 ], [ 0, 0, 0, 1 ] ];

    return matrix4Product(rot, matrix);
};

let matrix4RotatedYZ = function(matrix, alpha) {
    let c = Math.cos(alpha);
    let s = Math.sin(alpha);
    let rot = [ [ 1, 0, 0, 0 ], [ 0, c, -s, 0 ], [ 0, s, c, 0 ], [ 0, 0, 0, 1 ] ];

    return matrix4Product(rot, matrix);
};

