// Advent of Code 2023 - Day 13: Point of Incidence, part 1
// Mic, 2023

var input = document.getElementById('inputId');
var resultLabel = document.getElementById('result');

input.onchange = e => {
    var file = e.target.files[0];
    var reader = new FileReader();
    reader.readAsText(file, 'UTF-8');

    reader.onload = readerEvent => {
        var content = readerEvent.target.result;
        const allLines = content.split(/\r\n|\n/);
        let patterns = [];
        let p = [];
        allLines.forEach((line) => {
            if (line.length < 2) {
                patterns.push(p);
                p = [];
            } else {
                p.push([...line]);
            }
        });
        if (p.length > 0) patterns.push(p);

        const sum = patterns.reduce((acc, pattern) => {
           let v = findReflectionPoint(pattern);
           let h = findReflectionPoint(pattern[0].map((val, index) => pattern.map(row => row[row.length-1-index])));
           return acc + Math.max(h*100, v);
        }, 0);
        resultLabel.innerHTML = `Summarized pattern notes: ${sum}`;
    }
}

function isPalindrome(arr) {
    let p0 = 0;
    let p1 = arr.length - 1;
    let result = arr.length > 0;
    while (p1 > p0) {
        if (arr[p0] !== arr[p1]) return false;
        p0++; p1--;
    }
    return result;
}

function all(arr, predicate) { return arr.filter(predicate).length === arr.length; }

function findReflectionPoint(pattern) {
    const w = pattern[0].length;
    for (let n = w; n >= 2; n--) {
        for (const x of [w-n, 0]) {
            const x0 = x;
            const x1 = x0 + n;
            const match = all(pattern, (line) => isPalindrome(line.slice(x0, x1)));
            if (match) {
                return x + Math.floor(n / 2);
            }
        }
    }
    return 0;
}