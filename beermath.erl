-module(beermath).
-import(math, [pow/2, exp/1]).
-export([f2c/1, c2f/1, malt_bill/3, litres2gallons/1, gravity_correction/1]).

%% All functions use metric units (except conversions from non-metric units to metric units)
%% Conversions
% Fahrenheit to Celcius
f2c(F) -> (F - 32) * (5 / 9).
% Celcius to Fahrenheit
c2f(C) -> C * (9 / 5) + 32.
% Litres to gallons
litres2gallons(Litres) -> 0.2642 * Litres.
% Pounds to kilograms
lbs2kgs(Lbs) -> Lbs * 0.4536.


%% Calculate malt bill, all gravity units in GU's, GU = (SG - 1) * 1000
% Malts: A tuple having following format: {name, ExtractPotential, Efficiency, Proportion}
%       - name: malt name
%       - ExtractPotential: Extract potential for malt
%       - Efficiency: Mashing efficiency
%       - Proportion: Proportion of the malt from the total amount of malts
% VolumeLitras: Totals volume in litres
% TargetGravity: The target gravity
malt_bill(Malts, VolumeLitres, TargetGravity) -> malt_bill2(Malts, litres2gallons(VolumeLitres) * TargetGravity).
malt_bill2(Malts, TotalGravity) -> [{Malt, lbs2kgs(Proportion * TotalGravity / Efficiency / ExtractPotential) } || {Malt, ExtractPotential, Efficiency, Proportion} <- Malts].


%% Gravity calculations
% Gravity Temperature Correction by Lyons (1992)
gravity_correction(Celcius) -> gravity_correction(fahrenheit, c2f(Celcius)).

gravity_correction(fahrenheit, Fahrenheit) -> 1.313454 - 0.132674 * Fahrenheit + 0.002057793 * math:pow(Fahrenheit, 2) - 0.000002627634 * math:pow(Fahrenheit, 3).

%% IBU calculations
% Boil time factor
% The number 0.04 controls the shape of the utilization vs. time curve.
% The factor 4.15 controls the maximum utilization value
boil_time_factor(Mins) -> (1 - math:exp(-0.04 * Mins)) / 4.15.

% Bigness factor
% The numbers 1.65 and 0.000125 are empirically derived
bigness_factor(WortGravity) -> 1.65 * math:pow(0.000125, WortGravity - 1).

% Decimal alpha acid utilization 
aa_util(Mins, WortGravity) -> bigness_factor(WortGravity) * boil_time_factor(Mins).

aa_concentration(AlphaAcidRating, Grams, Volume) -> AlphaAcidRating * Grams * 1000 / Volume.

ibus(AlphaAcidRating, Grams, Volume, Mins, WortGravity) -> aa_util(Mins, WortGravity) * aa_concentration(AlphaAcidRating, Grams, Volume).

