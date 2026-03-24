# RentUp

Application **iOS** pour **hôtes** et propriétaires en **location courte durée** : centraliser annonces, réservations et indicateurs (revenus, charges, occupation) sans multiplier les outils.

## À quoi ça sert

RentUp aide à suivre plusieurs **biens** et **plateformes** (Airbnb, Booking, Abritel, etc.), à visualiser le **calendrier** des séjours et à analyser la **rentabilité** et l’**occupation** sur des périodes mensuelles, avec une logique de **répartition des nuits** entre les mois lorsque une réservation chevauche deux mois.

## Fonctionnalités principales

- **Compte** — Connexion (e-mail / mot de passe, Apple, Google), gestion du profil et des données liées au compte.
- **Annonces** — Fiche bien, tarification par plateforme, **comparateur** de revenus nets pour aligner les prix entre canaux.
- **Réservations** — Liste, calendrier avec distinction des plateformes et des chevauchements, actions sur les sélections.
- **Reporting** — Tableaux de bord et vues détaillées (rentabilité, occupation) cohérents avec la répartition par nuit.
- **Réglages** — Préférences de l’app, **import CSV** des réservations (format documenté dans l’app) après choix du bien associé.

## Technique (aperçu)

- **Langage & UI** — Swift, UIKit, mise en page avec SnapKit, composants dédiés.
- **Backend & sync** — Firebase Authentication, Cloud Firestore pour annonces et réservations.
- **Calendrier** — [HorizonCalendar](https://github.com/airbnb/HorizonCalendar) pour la vue mensuelle des réservations.
- **Autres dépendances notables** — Google Sign-In, IQKeyboardManager.

## Support

Pour toute question ou demande d’assistance : [michou855@hotmail.com](mailto:michou855@hotmail.com).
