const SOUP = [
  "b a n a n a q w e r t y u i o p",
  "a s d f g h j k l n z x c v b n",
  "j k l n z x c v b n m a n a n a",
  "a s d f g h j k l n z x c v b n",
  "f g h j k l n z x c v b n m a n",
  "a s d f g h j k l n z x c v b n",
  "l n z x c v b n m a n a n a s d",
  "p o i u y t r e w q a s d f g h",
  "k l n z x c v b n m a n a n a s",
  "a s d f g h j k l n z x c v b n",
  "n z x c v b n m a n a n a s d f",
  "a s d f g h j k l n z x c v b n",
  "a s d f g h j k l n z x c v b n",
  "a s d f g h j k l n z x c v b n",
  "a s d f g h j k l n z x c v b n",
  "a s d f g h j k l n z x c v b n",
];

const WORD = "ananab";
const WORD_SIZE = WORD.length;
const SOUP_SIZE = SOUP.length;

const findWord = (i, j, h, v) => {
  let col = j;
  let row = i;
  for (let k = 0; k < WORD_SIZE; k++) {
    if (col >= SOUP_SIZE || row >= SOUP_SIZE || col < 0 || row < 0) {
      return false;
    }
    if (SOUP[row][col] !== WORD[k]) {
      return false;
    }
    col += h;
    row += v;
  }
  return true;
};

const soupMap = () => {
  const wordFirstLetter = WORD[0];
  let colPos = 0;

  for (let i = 0; i < SOUP_SIZE; i++) {
    for (let j = 0; j < SOUP_SIZE; j+=2) {
      colPos++;
      if (SOUP[i][j] === wordFirstLetter) {
        if (findWord(i, j, 2, 0)) {
          console.log(`Palabra encontrada horizontalmente de izquierda
                    a derecha en la posición ${i + 1}, ${colPos}`);
          return;
        }
        if (findWord(i, j, -2, 0)) {
          console.log(`Palabra encontrada horizontalmente de derecha
                    a izquierda en la posición ${i + 1}, ${colPos}`);
          return;
        }
        if (findWord(i, j, 0, 1)) {
          console.log(`Palabra encontrada verticalmente de arriba
                    hacia abajo en la posición ${i + 1}, ${colPos}`);
          return;
        }
        if (findWord(i, j, 0, -1)) {
          console.log(`Palabra encontrada verticalmente de abajo
                    hacia arriba en la posición ${i + 1}, ${colPos}`);
          return;
        }
      }
    }
  }
  console.log("Palabra no encontrada");
  return;
};

const main = () => {
  const start = new Date();
  soupMap();
  const end = new Date();
  console.log(`Tiempo de ejecución: ${end - start} ms`);
};

main();
