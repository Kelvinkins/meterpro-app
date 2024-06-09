import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:meterpro/common/static.dart' as Static;
class Spinners
{

static SpinKitThreeBounce spinkitThreeBounce = const SpinKitThreeBounce(
  color: Colors.white,
  size: 30.0,
);
static SpinKitThreeBounce spinkitThreeBounceSmall = const SpinKitThreeBounce(
  color: Colors.white,
  size: 12.0,
);

static SpinKitThreeBounce spinkitThreeBounceBlue = const SpinKitThreeBounce(
  color: Static.PrimaryColor,
  size: 30.0,
);

static SpinKitThreeBounce spinkitThreeBounceBlueSmall = const SpinKitThreeBounce(
  color: Static.PrimaryColor,
  size: 12.0,
);

static SpinKitFadingCircle spinkitFadingCircle = const SpinKitFadingCircle(
  color: Static.PrimaryColor,
  size: 30.0,
);

}