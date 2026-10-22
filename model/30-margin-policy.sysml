// The margin policy every engineering budget of the mission applies: contingency by design
// maturity, a system-level margin per review gate, and the reusable constraints a budget
// asserts against them. Values are the project's own choice (fictional, in the range of
// published margin philosophies); the active row is the one for the next review.
package TethysMarginPolicy {
    private import ScalarValues::*;
    private import Quantities::*;

    enum def Maturity {
        doc /* Design maturity of a unit, which selects its contingency: flown-as-is heritage,
             * a modified heritage design, or a new development. */
        enum heritage;
        enum modified;
        enum newDesign;
    }

    enum def ReviewGate {
        doc /* The review a budget is reported against; each has its own policy row. */
        enum srr;
        enum pdr;
        enum cdr;
        enum acceptance;
    }

    attribute def MarginPolicyRow {
        doc /* One row of the margin policy table: the contingency fraction applied to a
             * unit's current best estimate by maturity, and the system margin the budget
             * must hold above the sum of allocations, at a given review. */
        attribute review : ReviewGate;
        attribute heritageContingency : Real;
        attribute modifiedContingency : Real;
        attribute newDesignContingency : Real;
        attribute systemMargin : Real;
    }

    attribute srrPolicy : MarginPolicyRow {
        doc /* Phase A close: 5 / 15 / 30 % contingency, 25 % system margin. */
        attribute :>> review = ReviewGate::srr;
        attribute :>> heritageContingency = 0.05;
        attribute :>> modifiedContingency = 0.15;
        attribute :>> newDesignContingency = 0.30;
        attribute :>> systemMargin = 0.25;
    }
    attribute pdrPolicy : MarginPolicyRow {
        doc /* Phase B close: 3 / 10 / 20 % contingency, 15 % system margin. */
        attribute :>> review = ReviewGate::pdr;
        attribute :>> heritageContingency = 0.03;
        attribute :>> modifiedContingency = 0.10;
        attribute :>> newDesignContingency = 0.20;
        attribute :>> systemMargin = 0.15;
    }
    attribute cdrPolicy : MarginPolicyRow {
        doc /* Phase C close: 2 / 5 / 10 % contingency, 10 % system margin. */
        attribute :>> review = ReviewGate::cdr;
        attribute :>> heritageContingency = 0.02;
        attribute :>> modifiedContingency = 0.05;
        attribute :>> newDesignContingency = 0.10;
        attribute :>> systemMargin = 0.10;
    }
    attribute acceptancePolicy : MarginPolicyRow {
        doc /* Measured hardware: 0 / 1 / 2 % contingency, 5 % system margin. */
        attribute :>> review = ReviewGate::acceptance;
        attribute :>> heritageContingency = 0.0;
        attribute :>> modifiedContingency = 0.01;
        attribute :>> newDesignContingency = 0.02;
        attribute :>> systemMargin = 0.05;
    }

    attribute activePolicy : MarginPolicyRow = pdrPolicy {
        doc /* The row every budget reads: the mission is in Phase B, so the PDR row. */
    }

    calc def ContingencyFor {
        doc /* The contingency fraction a policy row gives a unit of the stated maturity. */
        in maturity : Maturity;
        in policy : MarginPolicyRow;
        return fraction : Real =
            if maturity == Maturity::heritage ? policy.heritageContingency
            else if maturity == Maturity::modified ? policy.modifiedContingency
            else policy.newDesignContingency;
    }

    calc def WithContingency {
        doc /* A unit's allocation: its current best estimate grown by the contingency its
             * maturity earns under the policy. Dimensionally neutral: the result carries the
             * estimate's quantity kind. */
        in estimate : ScalarQuantityValue;
        in maturity : Maturity;
        in policy : MarginPolicyRow;
        return allocated : ScalarQuantityValue = estimate * (1.0 + ContingencyFor(maturity, policy));
    }

    calc def MarginFraction {
        doc /* The margin a capability holds over a demand, as a fraction of the demand:
             * (capability − demand) / demand. */
        in capability : ScalarQuantityValue;
        in demand : ScalarQuantityValue;
        return margin : Real = (capability - demand) / demand;
    }

    constraint def ClosesWithMargin {
        doc /* The reusable budget closure: the capability covers the demand with at least the
             * policy's system margin on top. Every budget in TethysBudgets asserts this with
             * its own capability, demand and the active policy row. */
        in capability : ScalarQuantityValue;
        in demand : ScalarQuantityValue;
        in policy : MarginPolicyRow;
        capability >= demand * (1.0 + policy.systemMargin)
    }

    constraint def WithinLimit {
        doc /* A predicted value stays inside a closed interval: the per-unit form a thermal,
             * pointing or dose check uses. */
        in predicted : ScalarQuantityValue;
        in lower : ScalarQuantityValue;
        in upper : ScalarQuantityValue;
        predicted >= lower and predicted <= upper
    }

    constraint def ReserveNotNegative {
        doc /* A consumable's reserve after every demand is met is not negative. */
        in loaded : ScalarQuantityValue;
        in demand : ScalarQuantityValue;
        loaded - demand >= 0.0 * loaded
    }
}
