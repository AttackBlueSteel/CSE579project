% Given facts

case(4, c, 90, 3000, 2000, 90).

referee(4, i, 480, 220, 0).

referee(5, i, 360, 140, 0).

referee(6, e, 480, 40, 700).

prefType(4, c, 0).

prefType(5, c, 2).

prefType(6, c, 3).

prefRegion(4, 2000, 3).

prefRegion(5, 2000, 2).

prefRegion(6, 2000, 2).

externalMaxDamage(1500).



% Assign each case to exactly one referee

1 { assign(CID, RID) : referee(RID, _, _, _, _) } 1 :- case(CID, _, _, _, _, _).



% Hard constraint: Do not exceed maximum workload for a referee

:- assign(CID, RID),

   case(CID, _, Effort, _, _, _),

   referee(RID, _, MaxWorkload, PrevWorkload, _),

   #sum { E, C : assign(C, RID), case(C, _, E, _, _, _) } > MaxWorkload - PrevWorkload.



% Hard constraint: A case must be assigned to a referee with a charge of the region

:- assign(CID, RID), case(CID, _, _, _, PostC, _),

   not prefRegion(RID, PostC, _).



% Hard constraint: A case must be assigned to a referee with a charge of the case type

:- assign(CID, RID), case(CID, Type, _, _, _, _),

   not prefType(RID, Type, _).



% Hard constraint: Cases with damage above a certain threshold must be assigned to internal referees

:- assign(CID, RID), case(CID, _, _, Damage, _, _), Damage > 1500, referee(RID, e, _, _, _).



% Assuming an arbitrary expected payment for illustration purposes

expected_payment(1000).



% Assuming an arbitrary expected workload for illustration purposes

expected_workload(600).



% Assuming the maximum preference level is 3

max_pref(3).



% Weak constraint: Balance the overall payment for external referees

:~ assign(CID, RID), case(CID, _, _, _, _, Payment), referee(RID, e, _, _, PrevPayment),

   expected_payment(ExpectedPayment),

   NewTotalPayment = PrevPayment + Payment, NewTotalPayment > ExpectedPayment.

   [NewTotalPayment - ExpectedPayment, CID, RID]



% Weak constraint: Balance the workload among all referees

:~ assign(CID, RID), case(CID, _, Effort, _, _, _), referee(RID, _, _, PrevWorkload, _),

   expected_workload(ExpectedWorkload),

   NewTotalWorkload = PrevWorkload + Effort, NewTotalWorkload > ExpectedWorkload.

   [NewTotalWorkload - ExpectedWorkload, CID, RID]



% Weak constraint: Prefer higher preference regions

:~ assign(CID, RID), case(CID, _, _, _, PostalCode, _), prefRegion(RID, PostalCode, Pref), max_pref(MaxPref),

   Pref < MaxPref. [MaxPref - Pref, CID, RID, PostalCode]



% Weak constraint: Prefer higher preference case types

:~ assign(CID, RID), case(CID, Type, _, _, _, _), prefType(RID, Type, Pref), max_pref(MaxPref),

   Pref < MaxPref. [MaxPref - Pref, CID, RID, Type]



% Specify what to display as the output

#show assign/2.

