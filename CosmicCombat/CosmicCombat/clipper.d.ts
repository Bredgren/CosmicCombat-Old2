
declare module ClipperLib {
    interface Vector {
        X: number
        Y: number
    }

    enum PolyType {
        ptSubject,
        ptClip
    }

    enum PolyFillType {
        pftEvenOdd,
        pftNonZero,
        pftPositive,
        pftNegative
    }

    enum ClipType {
        ctIntersection,
        ctUnion,
        ctDifference,
        ctXor
    }

    //class XArray<T> {
    //    constructor();
    //    pop(): T;
    //    push(val: T): T;
    //    length: number;
    //}

    interface Path extends Array<Vector> {
       // new (): Array<Vector>;
    }
    interface Paths extends Array<Path> {
        //new (): Array<Path>;
        //new <Path>(...items: Path[]): Path[];
        (...items: Path[]): Path[];
    }
    //interface Path extends Array<Vector> {
    //    new (arrayLength?: number): any[];
    //    new <Vector>(arrayLength: number): Vector[];
    //    new <Vector>(...items: Vector[]): Vector[];
    //    (arrayLength?: number): any[];
    //    <Vector>(arrayLength: number): Vector[];
    //    <Vector>(...items: Vector[]): Vector[];
    //    isArray(arg: any): boolean;
    //    prototype: Array<any>;
    //}
    //interface Paths extends Array<Path> {
    //    new (arrayLength?: number): any[];
    //    new <Paths>(arrayLength: number): Paths[];
    //    new <Paths>(...items: Paths[]): Paths[];
    //    (arrayLength?: number): any[];
    //    <Paths>(arrayLength: number): Paths[];
    //    <Paths>(...items: Paths[]): Paths[];
    //    isArray(arg: any): boolean;
    //    prototype: Array<any>;
    //}
    //var Path {
    //    new (arrayLength?: number): any[];
    //    new <Vector>(arrayLength: number): Vector[];
    //    new <Vector>(...items: Vector[]): Vector[];
    //    (arrayLength?: number): any[];
    //    <Vector>(arrayLength: number): Vector[];
    //    <Vector>(...items: Vector[]): Vector[];
    //    isArray(arg: any): boolean;
    //    prototype: Array<any>;
    //}
    //var Paths: {
    //    new (arrayLength?: number): any[];
    //    new <Paths>(arrayLength: number): Paths[];
    //    new <Paths>(...items: Paths[]): Paths[];
    //    (arrayLength?: number): any[];
    //    <Paths>(arrayLength: number): Paths[];
    //    <Paths>(...items: Paths[]): Paths[];
    //    isArray(arg: any): boolean;
    //    prototype: Array<any>;
    //}


    class ClipperBase {
        constructor();
        AddPaths(ppg: Paths, polyType: PolyType, closed: boolean);
    }

    class Clipper extends ClipperBase {
        constructor(InitOptions?: number);
    }

    module JS {
        //function ScaleUpPaths(path: Vector[], scale?: number);
    }

}