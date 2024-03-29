use debug::PrintTrait;
#[cairofmt::skip]
fn impreflex_goal() -> (Array<u8>, Array<u8>, Array<u8>) {
    'Impreflex goal ... '.print();
    'Reading proofs ... '.print();
    let gamma: Array<u8> = array![31, 0, 1];

    let claims: Array<u8> = array![137, 0, 137, 0, 5, 28, 30];

    let proofs: Array<u8> = array![
        137, 0, 137, 0, 137, 0, 5, 28, 5, 28, 29, 0, 137, 0, 29, 0, 137, 0, 5,
        5, 29, 2, 29, 0, 5, 137, 0, 29, 0, 137, 0, 13, 26, 3, 2, 1, 0, 137, 0,
        29, 0, 12, 26, 2, 1, 0, 21, 28, 27, 27, 27, 29, 3, 137, 0, 137, 0, 12,
        26, 2, 1, 0, 21, 28, 27, 27, 27, 29, 4, 30
    ];

    return (gamma, claims, proofs);
}
