# TODO

Ideas and planned features for NameScore.

## Planned

- [ ] **Rate hunter pets** – rate the names of other players' pets and show the score in the pet's tooltip.
  - Pet names are not unique (many hunters call their wolf "Wolfi"), so a pet needs its own key made of owner + pet name, e.g. `Pet:Drakner-Beansen:Wolfi`.
  - Owner can be read from the pet unit (e.g. `UnitIsOtherPlayersPet`, the pet's tooltip line "Pet of …").
  - Needs a right-click menu entry on pets and a small extension of the sync message format that stays compatible with older versions.
