import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const dati = JSON.parse(readFileSync('data/corsi.json', 'utf8'));
const corsi = Array.isArray(dati) ? dati : dati.corsi;  // ← adatta

test('il totale ore coincide con la somma delle unita formative', () => {
    for (const corso of corsi) {
        const somma = corso.unita.reduce((t, u) => t + u.ore, 0);
        assert.equal(corso.oreTotali, somma,
            `${corso.codice}: dichiarate ${corso.oreTotali}, sommate ${somma}`);
    }
});

test('ogni corso ha codice, titolo e almeno una unita formativa', () => {
    for (const corso of corsi) {
        assert.ok(corso.codice, 'un corso e senza codice');
        assert.ok(corso.titolo, `${corso.codice}: manca il titolo`);
        assert.ok(corso.unita?.length > 0, `${corso.codice}: nessuna UF`);
    }
});