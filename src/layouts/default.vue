<template>
  <div
    class="app" :class="{
      dark: isDark,
    }"
  >
    <main>
      <slot />
    </main>
  </div>
</template>
