import util.AssetPaths;
import util.Reg;
import states.PlayState;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxObject.*;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
//import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import openfl.Assets;

import zero.flxutil.camera.PlatformerDolly;
import zero.flxutil.ecs.Component;
import zero.flxutil.ecs.Entity;
import zero.flxutil.ecs.components.*;
import zero.flxutil.input.Controller;
import zero.flxutil.input.PlayerController;
import zero.flxutil.sprites.ParticleEmitter;
import zero.flxutil.sprites.ParticleEmitter.Particle;
import zero.flxutil.states.State;
import zero.flxutil.ui.ZBitmapText;
import zero.flxutil.util.GameLog;
import zero.flxutil.util.GameSave;
import zero.util.IntPoint;

using Math;

using zero.ext.ArrayExt;
using zero.ext.FloatExt;
using zero.ext.StringExt;
using zero.ext.flx.FlxObjectExt;
using zero.ext.flx.FlxPointExt;
using zero.ext.flx.FlxSpriteExt;