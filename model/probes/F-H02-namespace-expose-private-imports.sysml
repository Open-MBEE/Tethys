// F-H02: `expose P::*` in a view also exposes the members P privately imports.
// Run: sysml -render FH02::Tables::table -render-form markdown model/probes/F-H02-namespace-expose-private-imports.sysml
// Observed: the table lists every member of ISQ and SI (thousands of rows) beside the two
// item defs FH02::Items declares.
// Expected: the two item defs only — a private import is not a visible membership of
// FH02::Items, and a NamespaceExpose exposes the visible memberships of the exposed namespace
// (SysML v2 8.3.26.4 NamespaceExpose, KerML 8.3.2.3 NamespaceImport/importedMemberships).
package FH02 {
    package Items {
        private import ISQ::*;
        private import SI::*;
        item def Telemetry {
            doc /* Framed housekeeping data. */
            attribute volume : ISQ::MassValue;
        }
        item def Heat {
            doc /* Conducted thermal power. */
            attribute power : ISQ::PowerValue;
        }
    }
    package Tables {
        private import Views::*;
        view table {
            doc /* The members of Items as a table: two item defs expected. */
            expose Items::*;
            render asElementTable;
        }
    }
}
