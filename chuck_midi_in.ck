
/******************************************************/
/* GLOBAL VARIABLES                                   */
/******************************************************/
0.5::second => dur time_measure;



// MIDI setup
MidiIn min;
MidiMsg msg;

0 => int port; // need to check the port in Mini Audicle

/******************************************************/
/* Sound chain                                        */
/******************************************************/
// dry signal goes to chorus first then to delay:
adc => Chorus chorus => Gain dry_gain => dac;

// branch out the dry gain into delay line
dry_gain => Gain delay_gain => Delay delay => dac; 

// feedback
delay => Gain feedback_gain => delay;

// delay and gain settings
time_measure => delay.max;
0.5::time_measure => delay.delay;
0.4 => delay_gain.gain;
0.7 => dry_gain.gain;
0.25 => feedback_gain.gain;

// chorus settings
0.5::time_measure / second => chorus.modFreq;
0.25 => chorus.modDepth;
0.5 => chorus.mix;


if (!min.open(port)) {
    <<<"Error: MIDI port did not open", port>>>;
    me.exit();
} 

float pdx, pdy;

while (true)
{
    min => now;
    
    while (min.recv(msg)) {
	if (msg.data1 == 176 && msg.data2 == 60) {
		msg.data3 / 127.0 => pdx;
		pdx => chorus.mix;
	} else if (msg.data1 == 176 && msg.data2 == 61) {
		msg.data3 / 127.0 => pdy;
		pdy => delay_gain.gain => feedback_gain.gain;
	}
    }
}
