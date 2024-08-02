# Verse Item/Cosmetic Shop

## Setup

1. **Add `cosmetic_shop.verse` into your project.**

2. **Create a Niagara effect + VFX pickup with your cosmetic’s mesh** 
   - [Video Tutorial](https://youtu.be/alJFj42ms9w)

3. **Add a conditional button device and set a key and key amount (price) with the following settings:**
   - Consume items on activation: `true`
   - All key required at once: `true`
   - Interaction: `false` (optional)

4. **Add a switch device with the following settings:**
   - Allow interaction: `false`
   - Initial State: `false`
   - Store state per player: `true`
   - Use persistence: `true` (optional, if you want to let players keep unlocked cosmetics across games)

5. **Add a mutator zone and make sure `affects players` is true.**

6. **Repeat steps 2-5 for each cosmetic/item.**

7. **Add each item inside the device as shown in the video.**

8. **All assets used in the example video are included** 
   - Credit: [Sketchfab](https://skfb.ly/o8M6w)
   - Drag and drop `Effects` and `Items` folders into your project’s `content` folder (through Windows File Explorer, not through UEFN).
