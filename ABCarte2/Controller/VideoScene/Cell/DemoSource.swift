//
//  DemoSource.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

struct DataObj {
    var image: UIImage?
    var play_Url: URL?
    var title = ""
    var content = ""
}

class DemoSource: NSObject {
    static let shared = DemoSource()
    var demoData = [DataObj]()
    
    
    override init() {
        demoData += [
            DataObj(image: #imageLiteral(resourceName: "seven"),
                    play_Url: URL(string: "https://abcarte.s3-ap-northeast-1.amazonaws.com/videos/Video1.mp4")!,
                    title: "サンプル1",
                    content: "“Blessings (Reprise)” is Chance the Rapper shedding the skin he used to wear as an average human being. In his words: “The people’s champ must be everything the people can’t be.” He uses Coloring Book’s outro as an opportunity to step into the glimmering suit of optimism he’s been threading together since 2013’s Acid Rap, which shone light on more dark days than bright ones. His positive outlook on life in the present has been hard-fought, but rewarding; it’s apparent in his clarity that he’s exactly where he wants to be. With minimal vocals underscoring his single verse, the Chi-Town golden child spits bar after bar of faithfulness, letting it be known that he’s not afraid to talk to and about God in public. Chancellor Bennett is clearly a found man, and he’s doing his best to lead his fans to the promised land of happiness and well-being.\r\n\r\n"),
            DataObj(image: #imageLiteral(resourceName: "seven"),
                    play_Url: URL(string: "https://abcarte.s3-ap-northeast-1.amazonaws.com/videos/Video2.mp4")!,
                    title: "サンプル2",
                    content: "In this song, Mitski tells the story of a relationship that just isn't working out because of one very loaded word, \"American,\" and all the baggage it carries. The protagonist ends things, in part because she's tired of having to be someone she's not. The song builds to an epic chorus, in which Mitski slays her electric guitar and sings, \"you're an all-American boy / I guess I couldn't help trying to be your best American girl.\" In the end, she knows she doesn't need to apologize for who she is. \"Your mother wouldn't approve of how my mother raised me / But I do, I finally do,\" she sings. The song is brilliant for many reasons, but perhaps most of all for the way it forces us each to conjure up our \"all-American boy\" and then take issue with the fact that coming up with a picture of him was so easy.\r\n\r\n"),
            DataObj(image: #imageLiteral(resourceName: "seven"),
                    play_Url: URL(string: "https://abcarte.s3-ap-northeast-1.amazonaws.com/videos/Video3.mp4")!,
                    title: "サンプル3",
                    content: "“This is a God dream.” There are many ways to take this core phrase from the most haunting song this year has offered, uttered by the troubled seeker whose 2016 was both deeply fruitful and frighteningly off-kilter: as an expression of Kanye West’s desire to elevate himself beyond mere ego, or a way of sanctifying that ego; as a reminder of the need to honor the sacred or an assertion that secular music like his messy, vital, elusive, confrontational album The Life of Pablo can do that work while remaining true to the fallen spirit of the secular. As the track unfolds, West’s utterance starts to feel like a stage direction. Over a track that sounds like a couple of church musicians fiddling on the organ and a snare drum in an unlit sanctuary, West offers different voices the chance to articulate their God dreams. A child preacher sampled from Instagram shouts out the Devil. R&B mainstays Terius Nash and Kelly Price sing of trying to keep faith despite feeling abandoned, leading into a "),
            DataObj(image: #imageLiteral(resourceName: "seven"),
                    play_Url: URL(string: "https://abcarte.s3-ap-northeast-1.amazonaws.com/videos/Video4.mp4")!,
                    title: "サンプル4",
                    content: "Leonard Cohen died with just enough life to witness the release of his 14th and final record, You Want It Darker. The title track, one of the finest of his singular career, is hymnal and testament. It tells a tale of humans at their worst, of futility and belief. Cohen’s unmatched storytelling is why we revered him, but this one feels as if his intended audience was a higher power.\r\n\r\n"),
            DataObj(image: #imageLiteral(resourceName: "seven"),
                    play_Url: URL(string: "https://abcarte.s3-ap-northeast-1.amazonaws.com/videos/Video5.mp4")!,
                    title: "サンプル5",
                    content: "Many activists rightly point out that it's white folks' duty to combat racism by engaging with other white folks. That's the sort of meaningful, necessary work that Drive-By Truckers, a Southern rock band whose fan base skews Caucasian, undertakes here. Patterson Hood grits his teeth with barely contained fury as he memorializes Michael Brown and Trayvon Martin over muddied open chords. But for all the righteous anger, this doesn't feel like sermonizing. The Truckers don't claim to have the answers; they just know that no one gets to dodge responsibility for the violence that killed those kids or the systems perpetuating it. \"What It Means\" is the kind of protest song we can wish were a relic of a bygone time. Yet as the names of black and brown Americans killed by police continue to become hashtags, it remains insistently, bitterly relevant.\r\n\r\n")
        ]
    }
}
