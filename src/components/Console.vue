<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from "vue";
import { Carousel3d, Slide } from "vue3-carousel-3d";
import { io } from "socket.io-client";
import { NesVue, nes } from "nes-vue";
import QrcodeVue from "qrcode.vue";
import PulseLoader from "vue-spinner/src/PulseLoader.vue";

import game1 from "../assets/games/Super Mario Bros (JU).nes";
import game2 from "../assets/games/Super Mario Bros 3.nes";
import game3 from "../assets/games/Mighty Final Fight (USA).nes";
import game4 from "../assets/games/Mitsume ga Tooru (Japan).nes";
import game5 from "../assets/games/Contra Force (U) [o2].nes";
import swiperPath from "../assets/sounds/swiper.mp3";
import selectPath from "../assets/sounds/select.mp3";

import image1 from "../assets/images/8ec6bbb2-225c-410e-a98a-2248ab2dbd4a.png";
import image2 from "../assets/images/891b69da-7626-4a3a-9fba-fe970db5b4a6.png";
import image3 from "../assets/images/3a1c47bb-e0db-400f-92e0-1b79e3ff92e0.png";
import image4 from "../assets/images/1e3ba3cc-df67-44ce-a785-7f1011eeecb7.png";
import image5 from "../assets/images/30a8896d-5d41-4771-9b62-c43ac194398e.png";
const carousel = ref(null);
const carouselWidth = ref(0);
const carouselHeight = ref(0);
const selectedGame = ref();
const gameWidth = ref(512);
const gameHeight = ref(480);
const gameref = ref(null);
const socket = ref();
const isConnected = ref(false);
const connectPalyer1 = ref(false);
const connectPalyer2 = ref(false);
const uuid = ref();
const isStart = ref(false);

const BUTTON_A = 0;
const BUTTON_B = 1;
const BUTTON_SELECT = 2;
const BUTTON_START = 3;
const BUTTON_UP = 4;
const BUTTON_DOWN = 5;
const BUTTON_LEFT = 6;
const BUTTON_RIGHT = 7;

const swiperSound = ref(null);
const selectSound = ref(null);

const gameSliders = ref([
  {
    title: "Super Mario Bros",
    image: image1,
    game: game1,
  },
  {
    title: "Super Mario Bros 3",
    image: image2,
    game: game2,
  },
  {
    title: "Mighty Final Fight",
    image: image3,
    game: game3,
  },
  {
    title: "Mitsume ga Tooru",
    image: image4,
    game: game4,
  },
  {
    title: "Street Fighter",
    image: image5,
    game: game5,
  },
  {
    title: "Super Mario Bros",
    image: image1,
    game: game1,
  },
  {
    title: "Super Mario Bros 3",
    image: image2,
    game: game2,
  },
  {
    title: "Mighty Final Fight",
    image: image3,
    game: game3,
  },
  {
    title: "Mitsume ga Tooru",
    image: image4,
    game: game4,
  },
  {
    title: "Street Fighter",
    image: image5,
    game: game5,
  },
]);

const handleKeydown = (event) => {
  console.log(event.key);
  if (event.key === "ArrowRight") {
    if (selectedGame.value) return;
    carousel.value.goNext();
  } else if (event.key === "ArrowLeft") {
    if (selectedGame.value) return;
    carousel.value.goPrev();
  } else if (event.key === "Enter") {
    selectedGame.value = gameSliders.value[carousel.value.currentIndex];
  } else if (event.key === ",") {
    if (gameref.value) {
      gameref.value.screenshot(true);
    }
  } else if (event.key === ".") {
    connectPalyer1.value = true;
  } else if (event.key === "Backspace") {
    selectedGame.value = null;
  }
};

const socketClient = () => {
  socket.value = io("http://localhost:3000");
  socket.value.on("connect", () => {
    console.log("Bağlantı başarılı:", socket.value.connected);
    isConnected.value = socket.value.connected;
    socket.value.emit("login");
  });

  socket.value.on("disconnect", () => {
    console.log("Bağlantı koptu:", socket.value.connected);
    connectPalyer1.value = false;
    connectPalyer2.value = false;
    uuid.value = null;
    isConnected.value = socket.value.connected;
  });

  socket.value.on("uuid", (data) => {
    console.log("uuid:", data);
    uuid.value = data;
  });

  socket.value.on("player1", (data) => {
    if (data.hasOwnProperty("connected")) {
      connectPalyer1.value = data.connected;
      if (!connectPalyer1.value) {
        selectedGame.value = null;
      }
    } else if (data.hasOwnProperty("key")) {
      if (!selectedGame.value) {
        if (data.key == BUTTON_LEFT && data.event == "keydown") {
          playSwiperSound();
          carousel.value.goPrev();
        } else if (data.key == BUTTON_RIGHT && data.event == "keydown") {
          playSwiperSound();
          carousel.value.goNext();
        } else if (data.key == BUTTON_START && data.event == "keydown") {
          playSelectSound();
          selectedGame.value = gameSliders.value[carousel.value.currentIndex];
        }
      } else {
        if (data.key == "back") {
          selectedGame.value = null;
        } else {
          if (data.event == "keydown") {
            nes.buttonDown(1, data.key);
          } else {
            nes.buttonUp(1, data.key);
          }
        }
      }
    }
    console.log(data);
  });
  socket.value.on("player2", (data) => {
    if (data.hasOwnProperty("connected")) {
      connectPalyer2.value = data.connected;
    } else if (data.hasOwnProperty("key")) {
      if (data.event == "keydown") {
        nes.buttonDown(2, data.key);
      } else {
        nes.buttonUp(2, data.key);
      }
    }
    console.log(data);
  });
};

function playSwiperSound() {
  swiperSound.value.currentTime = 0;
  swiperSound.value.play();
}

function playSelectSound() {
  selectSound.value.currentTime = 0;
  selectSound.value.play();
}
const initSound = () => {
  swiperSound.value = new Audio(swiperPath);
  swiperSound.value.preload = "auto";
  selectSound.value = new Audio(selectPath);
  swiperSound.value.preload = "auto";
  swiperSound.value.volume = 0;
  swiperSound.value.play().then(() => swiperSound.value.pause());
  swiperSound.value.volume = 1;
  selectSound.value.volume = 0;
  selectSound.value.play().then(() => selectSound.value.pause());
  selectSound.value.volume = 1;
};

onMounted(() => {
  initSound();
  socketClient();
  updateCarouselSize();
  window.addEventListener("resize", updateCarouselSize);
  window.addEventListener("keydown", handleKeydown);
});

onBeforeUnmount(() => {
  window.removeEventListener("keydown", handleKeydown);
  window.removeEventListener("resize", updateCarouselSize);
});

const updateCarouselSize = async () => {
  await nextTick();
  const windowWidth = window.innerWidth;
  const windowHeight = window.innerHeight;
  carouselWidth.value = windowWidth / 2.5;
  carouselHeight.value = windowHeight / 1.5;
  gameHeight.value = windowHeight;
  gameWidth.value = windowWidth;
};
const onStart = () => {
  isStart.value = true;
};
</script>

<template>
  <VScaleTransition>
    <PulseLoader v-show="socket && !isConnected"></PulseLoader>
  </VScaleTransition>
  <VScaleTransition>
    <div
      v-if="uuid"
      v-show="!selectedGame && !connectPalyer1 && socket && isConnected"
    >
      <div v-if="!isStart">
        <v-btn @click="onStart">Başla</v-btn>
      </div>
      <div v-else style="border: 5px solid white">
        <QrcodeVue
          :value="uuid"
          :size="350"
          level="M"
          render-as="svg"
          background="#FFFFFF"
          foreground="#000000"
        ></QrcodeVue>
      </div>
    </div>
  </VScaleTransition>
  <VScaleTransition>
    <Carousel3d
      v-show="!selectedGame && connectPalyer1 && socket && isConnected"
      ref="carousel"
      loop
      :perspective="55"
      :display="gameSliders.length > 7 ? 7 : gameSliders.length"
      :controls-visible="true"
      :clickable="false"
      :controlsVisible="false"
      :height="carouselHeight"
      :width="carouselHeight"
    >
      <Slide :index="i" :key="i" v-for="(game, i) in gameSliders">
        <img class="responsive-img" :src="game.image" alt="" contain />
      </Slide>
    </Carousel3d>
  </VScaleTransition>
  <VScaleTransition>
    <div v-show="selectedGame">
      <div v-if="selectedGame">
        <NesVue
          ref="gameref"
          auto-start
          class="nes-container"
          :url="selectedGame.game"
          :width="gameWidth"
          :height="gameHeight"
        />
      </div>
    </div>
  </VScaleTransition>
</template>
<style lang="scss">
.nes-container {
  display: flex;
  justify-content: center;
  align-items: center;
  canvas {
    object-fit: cover;
    display: block;
  }
}

.responsive-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}
</style>