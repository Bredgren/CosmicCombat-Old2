//// Typing for the proton library 1.0.0
declare class Proton {
    constructor(proParticleCount?: number, integrationType?: string);
}

declare module Proton {
    class Particle {
//        constructor(pOBJ: ParticleParam);
    }

    class Emitter extends Particle {
        public rate: Rate;
        public p
        /**
         * add the Initialize to particles;
         * 
         * you can use initializes array:for example emitter.addInitialize(initialize1,initialize2,initialize3);
         * @method addInitialize
         * @param {Proton.Initialize} initialize like this new Proton.Radius(1, 12)
         */
        addInitialize(init: Initialize);
        addBehaviour(behaviours: Behaviour);
        emit();
    }

    class Rate {
        /**
         * The number of particles per second emission (a [particle]/b [s]);
         * @class Proton.Rate
         * @constructor
         * @param {Array or Number or Proton.Span} numpan the number of each emission;
         * @param {Array or Number or Proton.Span} timepan the time of each emission;
         * for example: new Proton.Rate(new Proton.Span(10, 20), new Proton.Span(.1, .25));
         */
        constructor(numpan, timepan);
    }

    class Span {
    }
    function getSpan(a: any, b?: number, center?: boolean);

    class ColorSpan extends Span {
    }

    class Initialize {
        constructor(a: any, b?: number, c?: boolean);
    }

    class Radius extends Initialize {
        //constructor(a: any, b?: number, c?: boolean);
    }

    class Life extends Initialize {
        //constructor(a: any, b?: number, c?: boolean);
    }

    class Velocity extends Initialize {
        constructor(rpan: Span, thapan: Span, type: string);
    }

//    Proton.ease = ease;
//    Proton.easeLinear = 'easeLinear';

//    Proton.easeInQuad = 'easeInQuad';
//    Proton.easeOutQuad = 'easeOutQuad';
//    Proton.easeInOutQuad = 'easeInOutQuad';

//    Proton.easeInCubic = 'easeInCubic';
//    Proton.easeOutCubic = 'easeOutCubic';
//    Proton.easeInOutCubic = 'easeInOutCubic';

//    Proton.easeInQuart = 'easeInQuart';
//    Proton.easeOutQuart = 'easeOutQuart';
//    Proton.easeInOutQuart = 'easeInOutQuart';

//    Proton.easeInSine = 'easeInSine';
//    Proton.easeOutSine = 'easeOutSine';
//    Proton.easeInOutSine = 'easeInOutSine';

//    Proton.easeInExpo = 'easeInExpo';
//    Proton.easeOutExpo = 'easeOutExpo';
//    Proton.easeInOutExpo = 'easeInOutExpo';

//    Proton.easeInCirc = 'easeInCirc';
//    Proton.easeOutCirc = 'easeOutCirc';
//    Proton.easeInOutCirc = 'easeInOutCirc';

//    Proton.easeInBack = 'easeInBack';
//    Proton.easeOutBack = 'easeOutBack';
//    Proton.easeInOutBack = 'easeInOutBack';

    class Behaviour {

    }

    class Color extends Behaviour {
        constructor(color1: ColorSpan, color2: ColorSpan, life?: number, easing?: string);
//        Color._super_.call(this, life, easing);
//        this.reset(color1, color2);
//        this.name = "Color";
    }

    class Alpha {
        constructor(a: Span, b: Span, life?: number, easing?: string);
    }

    class Renderer {
        constructor(type: string, proton: Proton, element: any);
        start();
    }
}
