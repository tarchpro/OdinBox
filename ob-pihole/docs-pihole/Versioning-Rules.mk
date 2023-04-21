VERSIONING

Odin-Box follows the default version rules from The Architect Project of #.#@.
    • (#).#@ - Numbers to the left of the decimal are major versions or revisions, defined either by mandatory security or major feature updates. Examples of reasons to use a new version number:
        ◦ A new security flaw has been discovered and that requires immediate attention and older versions should no longer be used for active environments
        ◦ A new TUI/GUI environment has been developed for the installer, and the old one is now depreciated
        ◦ Major new features such as adding IPv6 support or a new software addition has been added and the old version is now depreciated due to its lack of supported features
    • #.(#)@ - Numbers to the right of the decimal are minor revision numbers, defined either by addition of new optional feature, or optional feature updates. Examples of reasons to use a new revision number are:
        ◦ An important/commonly used feature has been patched for stability and older versions have a persistent bug
        ◦ A TUI/GUI change has occurred that is important to development, but not to the end user such as a color or font change
        ◦ The alpha number has surpassed Z and a new revision number is now required
    • #.#(@) - Letters to the right of the revision numbers, defined by minor revisions/improvements. Letters go from A-Z in the Roman/American English Alphabet, after Z a new minor revision number is required. Examples of reasons to use a new revision number are:
        ◦ A container variable has changed such as a containers default going from 1.4 to 1.41
        ◦ An update for minor stability has been issued
        ◦ A progressive/Quality of Life improvement has been added
        ◦ In code documentation has been updated
