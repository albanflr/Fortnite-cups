# Migration Supabase — Fortnite Cups

## Ce qui est préparé
- `import-cups.sql` importe les 178 entrées de tournois actuellement intégrées à `index.html`.
- Les données complètes de chaque cup sont conservées dans `competitions.details` afin de ne pas perdre les barèmes, qualifications, classements, récompenses et liens.
- Les horaires régionaux sont importés dans `sessions`.
- Le script est réexécutable et met à jour les lignes importées plutôt que de les dupliquer.

## Étape manuelle nécessaire
1. Ouvrir le projet Supabase, puis **SQL Editor**.
2. Ouvrir le fichier `supabase/import-cups.sql` dans ce dépôt GitHub.
3. Copier tout son contenu dans une nouvelle requête SQL Supabase et cliquer sur **Run**.
4. Vérifier que les deux requêtes de fin renvoient des nombres non nuls.

## Important
Cette migration remplit la base de données mais ne change pas encore la façon dont le site charge son calendrier. Le site continue donc d'utiliser ses données locales jusqu'à ce que la connexion côté navigateur soit configurée et testée. Ne publiez jamais de clé `service_role` ou `secret` dans le code du site. Seules l'URL du projet et la clé publishable/anon peuvent être utilisées côté navigateur avec les politiques RLS en place.


## Connexion automatique du site
Le fichier `index.html` essaie maintenant de lire les compétitions dans Supabase si `supabase-config.js` est configuré. Si la connexion échoue ou si la base est vide, le site conserve automatiquement son calendrier intégré.

Après l'import SQL :
1. Ouvrir `supabase-config.js` dans GitHub.
2. Cliquer sur le crayon **Edit**.
3. Remplacer `https://TON-PROJET.supabase.co` par l'URL du projet Supabase et `COLLE-ICI-LA-CLE-PUBLISHABLE` par la clé **Publishable** (ou l'ancienne clé `anon`).
4. Enregistrer avec **Commit changes**.

N'utiliser ni clé `secret`, ni `service_role`. Ne pas fusionner cette branche avant d'avoir exécuté l'import et testé le site.
