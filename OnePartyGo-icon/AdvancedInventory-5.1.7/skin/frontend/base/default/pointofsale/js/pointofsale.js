


function __initialize() {

    latlng = new google.maps.LatLng(places[0].lat, places[0].lng);
    myOptions = {
        zoom: 10,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };


    map = new google.maps.Map(document.getElementById("map_canvas_pointofsale"), myOptions);

    infowindows = new Array;
    markers = new Array;
    setPlaces()
    geoLocation();

    setTimeout(
            function() {
                if (W_GP.myAddress == null)
                    displaySearch(true)
            }, 10000)

}
function geoLocation() {
    // Try W3C Geolocation (Preferred)
    if (navigator.geolocation) {
        browserSupportFlag = true;
        navigator.geolocation.getCurrentPosition(function(position) {
            initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            map.setCenter(initialLocation);
            findPlace(null, initialLocation)

        }, function() {
            handleNoGeolocation(browserSupportFlag);

        });
        // Try Google Gears Geolocation
    } else if (google.gears) {
        browserSupportFlag = true;
        var geo = google.gears.factory.create('beta.geolocation');
        geo.getCurrentPosition(function(position) {
            initialLocation = new google.maps.LatLng(position.latitude, position.longitude);
            map.setCenter(initialLocation);
            findPlace(null, initialLocation);

        }, function() {
            handleNoGeoLocation(browserSupportFlag);

        });
        // Browser doesn't support Geolocation
    } else {
        browserSupportFlag = false;
        handleNoGeolocation(browserSupportFlag);

    }
    return false
}

function handleNoGeolocation(errorFlag) {
    displaySearch(true)
    displayStore(0)
}

function displaySearch(error) {

    if (error) {
        msg = Builder.node("span", [W_GP.strings.unableToFindYourLocation, Builder.node("br")])
        value = W_GP.strings.enterYourLocation;
    }
    else {
        msg = Builder.node("span",{className: 'tools-new-location'} , [W_GP.strings.setANewLocation, Builder.node("br")]);
        value = W_GP.myAddress;
    }

    myPlace = Builder.node("div", [
        msg,
        Builder.node("span",[
            Builder.node("input", {"id": "geocoder", "value": value, "onclick": "this.value=''"}),
            Builder.node("button", {"onclick": "findPlace($('geocoder').value)"}, W_GP.strings.findMe)
        ])
    ])

    $('tools').update(myPlace);

}

function displayMyAddress(myAddress) {
    myPlace = Builder.node("div", [
        Builder.node("span",{className: 'tools-location'}, W_GP.strings.yourLocation + " : "),
        Builder.node("span",{className: 'tools-address'}, Builder.node("b", myAddress)),
        Builder.node("span", {className: 'tools-buttons'}, [
            Builder.node("a", {"href": "javascript:displaySearch(false)"}, W_GP.strings.changeMyLocation),
            Builder.node("a", {"href": "javascript:javascript:displayLocation(W_GP.myAddress,true)"}, W_GP.strings.showMyLocation)
        ])
    ])

    $('tools').update(myPlace);
}



//Conversion des degrés en radian
function convertRad(input) {
    return (Math.PI * input) / 180;
}

function Distance(lat_a_degre, lon_a_degre, lat_b_degre, lon_b_degre) {

    R = 6378000 //Rayon de la terre en mètre

    lat_a = convertRad(lat_a_degre);
    lon_a = convertRad(lon_a_degre);
    lat_b = convertRad(lat_b_degre);
    lon_b = convertRad(lon_b_degre);

    d = R * (Math.PI / 2 - Math.asin(Math.sin(lat_b) * Math.sin(lat_a) + Math.cos(lon_b - lon_a) * Math.cos(lat_b) * Math.cos(lat_a)))
    return d;
}

function findPlace(myAddress) {
    closeDirection();
    geocoder = new google.maps.Geocoder();
    if (typeof arguments[1] != "undefined")
        data = {location: arguments[1]};
    else
        data = {'address': myAddress};
    geocoder.geocode(data, function(results, status) {
        if (typeof dirRenderer != 'undefined')
            dirRenderer.setMap(null);
        if (status == google.maps.GeocoderStatus.OK) {
            if (results[0]) {


                updateList('*');
                h = 0;
                coord = new Array;
                coord[0] = results[0].geometry.location.lat();
                coord[1] = results[0].geometry.location.lng();
//                for (val in results[0].geometry.location) {
//                    coord[h] = results[0].geometry.location[val]
//                    h++;
//                }

                myLatLng = new google.maps.LatLng(coord[0], coord[1]);

                i = 0;

                stores.each(function(s) {
                     s.distance = Distance(coord[0], coord[1], s.position.lat(), s.position.lng())
                })
                storeTemp = new Array();
                storeTemp = stores.sortBy(function(s) {
                    return s.distance.round();
                });


                storeList = new Array();
                storeListTemp = new Array();
                i = 0;
                storeTemp.each(function(s) {

                    if (i < 25) {
                        storeListTemp.push(s)
                        storeList.push(s.position);
                    }
                    i++;
                })


                var service = new google.maps.DistanceMatrixService();
                service.getDistanceMatrix(
                        {
                            origins: [myLatLng],
                            destinations: storeList,
                            travelMode: google.maps.TravelMode.DRIVING,
                            unitSystem: google.maps.UnitSystem.METRIC,
                            avoidHighways: false,
                            avoidTolls: false
                        }, function(response, statusDistance) {
                    if (statusDistance === "OK") {

                        getDistances(response);
                    }
                    else
                        alert(W_GP.strings.distanceCalculationFailed + statusDistance);

                    myAddress = results[0].formatted_address
                    W_GP.myAddress = results[0].formatted_address
                    displayLocation(myAddress);

                });
            } else {
                alert(W_GP.strings.noResultFound);
            }
        } else {
            alert(W_GP.strings.unableToFindYourLocation);
        }
    });

}

function getStoreIndexById(id) {
    i = 0;
    index = null;
    places.each(function(p) {
        if (p.id == id)
            index = i;
        i++;
    })
    return index;
}
function getStoreIdByIndex(index) {
    i = 0;
    id = null;
    places.each(function(p) {
        if (i == index)
            id = p.id;
        i++;
    })
    return id;
}
//
// Récupérer les infos de distances
//

function   getDistances(response) {

    myStore = {
        "status": false,
        'duration': {
            'text': null,
            'value': null
        },
        'distance': {
            'text': null,
            'value': null
        }
    };
    s = 0;

    places.each(function(p) {
        places[s].status = false;
        places[s].duration.value = null;
        places[s].duration.text = null;
        places[s].distance.value = null;
        places[s].distance.text = null;
        s++;
    })
    s = 0;
    response.rows[0].elements.each(function(e) {
        if (e.status != "ZERO_RESULTS") {


            index = getStoreIndexById(storeListTemp[s].id);
            places[index].status = true;
            places[index].duration.value = e.duration.value
            places[index].duration.text = e.duration.text
            places[index].distance.value = e.distance.value
            places[index].distance.text = e.distance.text
            if (!myStore.status || e.duration.value < myStore.duration.value) {
                myStore.status = true;
                myStore.duration.value = e.duration.value
                myStore.duration.text = e.duration.text
                myStore.distance.value = e.distance.value
                myStore.distance.text = e.distance.text
                myStore.index = index

            }
        }
        else
            places[s].status = false;
        s++;

    })

}

//
// affiche la position actuelle et affiche la bulle 
//   

function displayLocation(myAddress) {

    var blueIcon = new google.maps.MarkerImage("//www.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png");


    if (typeof myLocation === "undefined") {
        myLocation = new google.maps.Marker({
            position: myLatLng,
            map: map,
            icon: blueIcon

        });
        google.maps.event.addListener(myLocation, 'click', function() {
            displayLocation(myAddress, true)
        });
    }
    else
        myLocation.setPosition(myLatLng);

    if (myStore.status) {
        infowindow.setContent("<h4><b>" + W_GP.strings.youAreHere + "</b></h4><br>" + W_GP.strings.theClosestStoreIs + " <b><a href='javascript:displayStore(" + myStore.index + ")'/>" + places[myStore.index].name + "</a></b><br> " + myStore.distance.text + " - " + myStore.duration.text + "<br><a href='javascript:getDirections()'>" + W_GP.strings.getDirections + "</a>");
        blindStore(myStore.index);
    }
    else {
        infowindow.setContent("<h4><b>" + W_GP.strings.youAreHere + "</b></h4><br/><b>" + W_GP.strings.noStoreLocated + "</b>");
    }
    if (!arguments[1]) {
        zoom = 12 - Math.round((myStore.distance.value * 100 / 500000) * (12 / 100))
        if (zoom < 4)
            zoom = 4;
        map.setZoom(zoom);
    }
    infowindow.open(map, myLocation)

    map.panTo(myLatLng);
    displayMyAddress(myAddress)

}

// 
// centre la carte sur le store, affiche la bulle et ouvre la fiche magasin
// 
function displayStore(index) {

    var latlng = new google.maps.LatLng(places[index].lat, places[index].lng)

    map.panTo(latlng);
    content = places[index].title;
    if (places[index].status) {
        content += "<br>" + places[index].distance.text + " - " + places[index].duration.text + " " + W_GP.strings.from + " " + "<a href='javascript:displayLocation(W_GP.myAddress,true)'>" + W_GP.myAddress + "</a><br>"
        content += places[index].links.directions + " | ";
    }
    else
        content += '<br>';
    content += places[index].links.showOnMap;
    infowindow.setContent(content);

    infowindow.open(map, markers[index])

    blindStore(index)


}


//
// Slide vers le store concerné
//
function blindStore(index) {
    id = getStoreIdByIndex(index)
    $$('#pointofsale_scroll .details[id!=place_' + id + ']').each(function(d) {
        if (d.visible())
            Effect.BlindUp(d.id, 'slide');
    })
    if (!$("place_" + id).visible()) {

        $("place_" + id).blindDown({afterFinish: function() {
                offset=20;
                increment=3
                posArray = $("place_" + id).ancestors()[0].positionedOffset();
                from = $('pointofsale_scroll').scrollTop;
                to = posArray[1]-offset;
                go = from;
               
                scroll = setInterval(function() {
                    if (from > to) {
                        go -= i*increment;
                        if (go <= to)
                            clearInterval(scroll);
                    }
                    else {
                        go += i*increment;
                        if (go >= to)
                            clearInterval(scroll);
                    }
                    $('pointofsale_scroll').scrollTop = go;
                    i++;




                }, 100);


            }})
    }

    if (typeof PickupAtStore != "undefined") {
        $('pickupatstore_' + id).selected = true;
        PickupAtStore.update();
    }
}

//
// Places tous les marqueurs sur la carte
//

function setPlaces() {
    stores = new Array()
    i = 0;
    places.each(function(p) {

        infowindow = new google.maps.InfoWindow();
        var latlng = new google.maps.LatLng(p.lat, p.lng);

        markers[i] = new google.maps.Marker({
            position: latlng,
            map: map,
            id: p.id
        });


        google.maps.event.addListener(markers[i], 'click', function() {
            displayStore(getStoreIndexById(this.id))
        });
        // liste des positions des stores


        stores.push({id: p.id, position: markers[i].position})
        i++;
    });
}
//
// Mise à jour de la liste
//
function updateList() {
    if ($('country_place')) {
        if (arguments[0])
            $('country_place').value = arguments[0];
        $$(".place").each(function(c) {
            if ($('country_place').value != "*")
                c.hide();
            else
                c.show();
        });
        if ($('country_place').value != "*") {
            $$("." + $('country_place').value).each(function(c) {
                c.show();
            });
        }
    }
}



function getDirections() {
    updateList('*');
    if (typeof dirRenderer != 'undefined')
        dirRenderer.setMap(null);
    dirService = new google.maps.DirectionsService();
    dirRenderer = new google.maps.DirectionsRenderer({suppressMarkers: true, suppressInfoWindows: true});

    $('directions').update('')
    var fromStr = W_GP.myAddress;
    if (typeof arguments[0] == "undefined")
        var toStr = places[myStore.index].lat + ',' + places[myStore.index].lng;
    else
        var toStr = places[arguments[0]].lat + ',' + places[arguments[0]].lng;
    var dirRequest = {
        origin: fromStr,
        destination: toStr,
        travelMode: google.maps.DirectionsTravelMode.DRIVING,
        unitSystem: google.maps.DirectionsUnitSystem.METRIC,
        provideRouteAlternatives: true
    };
    dirService.route(dirRequest, function(dirResult, dirStatus) {
        dirRenderer.setMap(map);
        $('dirRendererBlock').setStyle({display: 'block'})
        dirRenderer.setPanel($('directions'));
        dirRenderer.setDirections(dirResult);
        infowindow.close()
    });

}

function closeDirection() {
    if (typeof dirRenderer != 'undefined')
        dirRenderer.setMap(null);
    $('directions').update('')
    $('dirRendererBlock').hide()
}
