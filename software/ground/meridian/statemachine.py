"""An interpreter for the generated state-machine tables (``argent_tables.state_machines``): the
ground lifecycles ``AlarmLifecycle`` and ``AnomalyLifecycle`` run from their rows, not from code."""

from __future__ import annotations

from argent_tables.state_machines import StateMachine


class TableStateMachine:
    """Flat (single-region) machine: start at the initial state, follow the transition whose source
    is the current state and whose event is the one accepted."""

    def __init__(self, table: StateMachine):
        self.table = table
        self.state = table.initial
        self.history = [table.initial]

    @property
    def state_name(self) -> str:
        return self.state.rsplit("::", 1)[-1] if self.state else ""

    def transitions_from(self, state: str):
        return [t for t in self.table.transitions if t.source == state]

    def accept(self, event: str) -> bool:
        for t in self.transitions_from(self.state):
            if t.event == event:
                self.state = t.target
                self.history.append(t.target)
                return True
        return False
