# RotaCloud
RotaCloud tech test

This is a tech test I did for a local company 'Rotacloud'. It retreives data about launches from
SpaceX's servers via a RESTful interface and displays them in master-detail iOS app.

Spec:

## SpaceX Rockets

Build a simple app to fetch and present information to the user regarding SpaceX rockets.

You can find a JSON payload of the rockets at **https://api.spacexdata.com/v3/rockets**, along with documentation regarding the API/Endpoint at **https://docs.spacexdata.com/?version=latest#16c58b5e-44de-4183-b858-0fae51d242a5**.

#### What's Expected
A simple app that presents the user with a list of SpaceX rockets and allows the user to explore details of those rockets.

At a minimum you should:

- Fetch the JSON payload from the endpoint
- Decode it into a model.
- Present the model across 2 view controllers, one showing the rocket names, and the other showing details for the selected rocket.

Nice to have features would include:

- Decoding dates into Date objects, rather than strings.
- Decoding enumeration values into enumerations.
- Decoding json keys such as `cost_per_launch` as `costPerLaunch` (convert keys from snake case to camel case).
- Correctly formatting units and values.

The app should run on iOS 11+ and use Swift 5+. It does not need to be optimized for iPad though.

Aim to spend no more than 1hr 30mins on the task.
