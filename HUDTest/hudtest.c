#include <gb/gb.h>
#include <stdio.h>
#include <gb/font.h>
#include "bgTiles.c"
#include "bg0.c"
// #include "windowmap.c"


void main() {
	font_t min_font;

	font_init();
	min_font = font_load(min_font); // 37 tile
	font_set(min_font);

	// set_win_tiles(0, 0, 5, 1, windowmap);

	set_bkg_data(38, 7, backgroundTiles);
	set_bkg_tiles(0, 0, 40, 18, background0);

	SHOW_BKG;
	// SHOW_WIN;
	DISPLAY_ON;

	while(1) {
		scroll_bkg(1,0);
		delay(100);
	}
}