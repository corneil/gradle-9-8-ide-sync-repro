# IntelliJ IDEA Gradle sync fails with Gradle >= 9.8.0 ("Unknown cause")

Gradle sync in IntelliJ IDEA Ultimate 2026.2.3 (Build #IU-262.10968.63) ends with an error
icon and no message on Gradle 9.8.0 or newer. It syncs cleanly on 9.7.1 and older, and the
result can depend on which version was synced before. The command line build succeeds on every version.

## Reproduce

Use a fresh IDE session if possible. Open this project in IntelliJ IDEA 2026.2.3
(Gradle JVM: JDK 21) and sync after each step. `./switch-gradle.sh <version>` only edits
`gradle/wrapper/gradle-wrapper.properties`.

| Step | Wrapper | Observed |
|------|---------|----------|
| 1 | `./switch-gradle.sh 9.7.1` | OK on first sync (see note) |
| 2 | `./switch-gradle.sh 9.8.0` | FAIL: error icon, no message |
| 3 | `./switch-gradle.sh 9.7.1` | FAIL: same project and same version as step 1 |
| 4 | `./switch-gradle.sh 9.5.1` | OK |

Step 3 failing after step 1 passed means the result depends on state left behind by an
earlier sync, not only on the Gradle version. `.gradle/`, `build/` and `.idea/` are
git-ignored, so deleting them between steps shows whether the project directory holds
that state.

Note: in my other projects the first-ever sync on 9.7.x also failed, so 9.7.0+ may fail
from the start. Record the first result on a clean checkout.

## Results from the larger projects (Gradle version matched to the sync by daemon start time)

| Gradle | IDE sync |
|--------|----------|
| 9.5.1, 9.6.0, 9.6.1 | OK |
| 9.7.0, 9.7.1, 9.8.0, 9.8.1, 9.8.2 | FAIL |

## idea.log

```
INFO - GradleSyncStateHolder$SyncStateUpdater - onFailure(RESOLVE_PROJECT:N,
    com.intellij.openapi.externalSystem.service.internal.ExternalSystemPartialResolutionException: )
WARN - GradleSyncStateHolder - No error message given
WARN - GradleSyncStateHolder - Gradle sync failed in ... Unknown cause
```

Stack: `GradleProjectResolver.resolveProjectInfo(GradleProjectResolver.java:217)`.
The exception is thrown when `DefaultProjectResolverContext.getReporter().hasFailures()`
is true. The exception message is empty.

## What was ruled out

Running the IDE's own init scripts and arguments (`ijMapper`, `sync.studio.tooling`,
`ijInit`, `-Pandroid.injected.*`) through the Tooling API on 9.6.1 and 9.7.1 gives the same
result: model fetch succeeds, no failed operations, and the Problems API events are
identical (no ERROR problems). So the failure is raised inside the IDE's sync, not by a
failing build step.
