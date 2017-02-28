/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import SwiftyJSON

/** The score of a particular tone. */
public struct ToneScore {
    
    /// A unique number identifying this particular tone.
    public let id: String
    
    /// The name of this particular tone.
    public let name: String
    
    /// The raw score of the tone, computed by the algorithms. This can be
    /// compared to other raw scores and used to build your own normalizations.
    public let score: Double
    
    /// Used internally to initialize a `ToneScore` model from JSON.
    public init(json: JSON) {
        id = json["tone_id"].stringValue
        name = json["tone_name"].stringValue
        score = json["score"].doubleValue
    }
}
