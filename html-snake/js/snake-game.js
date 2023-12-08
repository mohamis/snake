const canvas = document.getElementById('snakeCanvas');
const ctx = canvas.getContext('2d');
const scoreElement = document.getElementById('score');

function setCanvasSize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}

setCanvasSize();

const snakeSize = 20;
let snake = [{ x: 100, y: 100 }];
let direction = 'right';
let food = { x: 0, y: 0 };
let score = 0;

function drawSnake() {
    ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear the canvas
    ctx.fillStyle = '#4608E0';
    snake.forEach(segment => {
        ctx.fillRect(segment.x, segment.y, snakeSize, snakeSize);
    });
}

function moveSnake() {
    const head = { ...snake[0] };

    switch (direction) {
        case 'up':
            head.y -= snakeSize;
            break;
        case 'down':
            head.y += snakeSize;
            break;
        case 'left':
            head.x -= snakeSize;
            break;
        case 'right':
            head.x += snakeSize;
            break;
    }

    snake.unshift(head);

    // Check if the snake eats the food
    if (head.x === food.x && head.y === food.y) {
        score++;
        generateFood();
    } else {
        snake.pop(); // Remove the tail segment if not eating food
    }

    // Check for collisions with the walls or itself
    if (
        head.x < 0 ||
        head.y < 0 ||
        head.x >= canvas.width ||
        head.y >= canvas.height ||
        checkCollision()
    ) {
        gameOver();
    }
}

function changeDirection(e) {
    switch (e.key) {
        case 'ArrowUp':
            direction = 'up';
            break;
        case 'ArrowDown':
            direction = 'down';
            break;
        case 'ArrowLeft':
            direction = 'left';
            break;
        case 'ArrowRight':
            direction = 'right';
            break;
    }
}

function generateFood() {
    food = {
        x: Math.floor(Math.random() * (canvas.width / snakeSize)) * snakeSize,
        y: Math.floor(Math.random() * (canvas.height / snakeSize)) * snakeSize,
    };
}

function drawFood() {
    ctx.fillStyle = 'red';
    ctx.fillRect(food.x, food.y, snakeSize, snakeSize);
}

function checkCollision() {
    const head = snake[0];
    for (let i = 1; i < snake.length; i++) {
        if (head.x === snake[i].x && head.y === snake[i].y) {
            return true; // Collision with itself
        }
    }
    return false;
}

function gameOver() {
    alert('Game Over! Your score is ' + score);
    snake = [{ x: 100, y: 100 }];
    direction = 'right';
    score = 0;
    generateFood();
}

function updateScore() {
    scoreElement.textContent = 'Score: ' + score;
}

function gameLoop() {
    moveSnake();
    drawSnake();
    drawFood();
    updateScore();
}

document.addEventListener('keydown', changeDirection);
window.addEventListener('resize', setCanvasSize);

generateFood(); // Initial food generation
setInterval(gameLoop, 100);
