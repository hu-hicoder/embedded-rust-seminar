#![no_std]
#![no_main]

use defmt_rtt as _;
use panic_probe as _;
use rp_pico::{self as bsp, XOSC_CRYSTAL_FREQ};

use bsp::{entry, hal, pac};
use cortex_m::delay;
use embedded_hal::pwm::SetDutyCycle;
use rp_pico::hal::prelude::*;

const PWM_TOP: u16 = 28488;

#[entry]
fn main() -> ! {
    let mut pac = pac::Peripherals::take().unwrap();
    let core = pac::CorePeripherals::take().unwrap();

    let mut watchdog = hal::Watchdog::new(pac.WATCHDOG);

    let clocks = hal::clocks::init_clocks_and_plls(
        XOSC_CRYSTAL_FREQ,
        pac.XOSC,
        pac.CLOCKS,
        pac.PLL_SYS,
        pac.PLL_USB,
        &mut pac.RESETS,
        &mut watchdog,
    )
    .unwrap();

    let sio = hal::Sio::new(pac.SIO);

    let pins = bsp::Pins::new(
        pac.IO_BANK0,
        pac.PADS_BANK0,
        sio.gpio_bank0,
        &mut pac.RESETS,
    );

    let mut delay = delay::Delay::new(core.SYST, clocks.system_clock.freq().to_Hz());

    let pwm_slice = hal::pwm::Slices::new(pac.PWM, &mut pac.RESETS);

    let mut pwm = pwm_slice.pwm0;
    pwm.enable();
    pwm.clr_ph_correct();
    pwm.set_top(PWM_TOP);
    pwm.set_div_int(10);
    pwm.set_div_frac(0);

    let channel = &mut pwm.channel_a;
    channel.output_to(pins.gpio0);

    loop {
        delay.delay_ms(1000u32);
        channel.set_duty_cycle(PWM_TOP / 2).unwrap();
        delay.delay_ms(1000u32);
        channel.set_duty_cycle(0).unwrap();
    }
}
